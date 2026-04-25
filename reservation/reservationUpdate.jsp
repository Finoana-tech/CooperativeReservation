<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.List, model.*, dao.*" %>
<%
    ReservationDAO reservationDAO = new ReservationDAO();
    ClientDAO clientDAO = new ClientDAO();
    VoitureDAO voitureDAO = new VoitureDAO();
    
    String idreserv = request.getParameter("id");
    Reservation reservation = reservationDAO.getById(idreserv);
    
    List<Reservation> toutesLesPlaces = reservationDAO. getAllByCodeReserv(idreserv);
    StringBuilder placesInitiales = new StringBuilder();
    for(int i=0; i<toutesLesPlaces.size(); i++) {
        placesInitiales.append(toutesLesPlaces.get(i).getPlace());
        if(i < toutesLesPlaces.size() - 1) placesInitiales.append(",");
    }

    List<Client> clients = clientDAO.getAll();
    List<Voiture> voitures = voitureDAO.getAll();
    
    int avanceCumulee = 0;
    for(Reservation r : toutesLesPlaces) {
        avanceCumulee += r.getMontantAvance();
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifier Réservation - Gestion Coopérative</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root { --primary-color: #1a3a5f; --bg-color: #f8f9fa; --white: #ffffff; --accent: #ffc107; --blue-selected: #0d6efd; --grey-occupied: #e9ecef; }
        body { background-color: var(--bg-color); font-family: 'Segoe UI', sans-serif; min-height: 100vh; display: flex; flex-direction: column; }
        .main-header { background-color: var(--primary-color); color: white; padding: 25px 0; }
        .form-card { background: var(--white); border: 1px solid #dee2e6; border-radius: 4px; padding: 25px; max-width: 700px; margin: 30px auto; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .form-label { font-weight: bold; text-transform: uppercase; font-size: 0.75rem; color: var(--primary-color); margin-bottom: 5px; display: block; }
        .btn-update { background-color: var(--primary-color); color: white; border: none; padding: 15px; width: 100%; font-weight: bold; text-transform: uppercase; margin-top: 15px; border-radius: 4px; transition: 0.3s; }
        .btn-update:hover { background-color: #2a4d7d; transform: translateY(-2px); }
        .id-badge { background-color: rgba(255,255,255,0.2); color: white; padding: 5px 15px; border-radius: 20px; font-size: 0.8rem; font-weight: bold; border: 1px solid white; display: inline-block; }
        
        /* GRILLE ET ETATS DES PLACES ADAPTÉS */
        .seat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-top: 15px; background: #f1f3f5; padding: 15px; border-radius: 8px; }
        .seat { padding: 12px; text-align: center; border-radius: 6px; font-weight: bold; font-size: 0.9rem; transition: 0.2s; min-width: 45px; }
        
        /* BLANCHE : Libre */
        .available-white { background-color: #ffffff; border: 2px solid var(--blue-selected); cursor: pointer; color: #000; }
        .available-white:hover { background-color: #f0f7ff; }
        
        /* GRISÂTRE : Occupé par autrui (Bloqué) */
        .occupied-grey { background-color: var(--grey-occupied); color: #adb5bd; border: 1px solid #dee2e6; cursor: not-allowed; pointer-events: none; }
        
        /* BLEU PLEIN : Vos places (Cliquables pour décocher) */
        .selected-blue { background-color: var(--blue-selected) !important; color: white !important; border: 2px solid #004299 !important; cursor: pointer; transform: scale(1.05); }
        
        footer { padding: 20px 0; font-size: 0.8rem; color: #6c757d; border-top: 1px solid #dee2e6; background: white; margin-top: auto; }
    </style>

    <script>
        const voiturePrices = {
            <% for (Voiture v : voitures) { %>
                "<%= v.getIdvoit() %>": <%= v.getFrais() %>,
            <% } %>
        };

        // Initialisation avec les places déjà réservées
        let selectedSeats = "<%= placesInitiales.toString() %>".split(",").filter(s => s !== "").map(Number);

        function toggleAvance() {
            var payment = document.getElementById("payment").value;
            var avanceDiv = document.getElementById("avanceDiv");
            var inputAvance = document.getElementById("montant_avance");
            
            if (payment === "avec avance") {
                avanceDiv.style.display = "block";
                inputAvance.required = true;
            } else {
                avanceDiv.style.display = "none";
                inputAvance.required = false;
                inputAvance.value = "0";
            }
        }

        function loadAvailableSeats() {
            var idvoit = document.getElementById("idvoitSelect").value;
            var date = document.getElementById("dateVoyage").value;
            var idreserv = "<%= idreserv %>";
            var seatArea = document.getElementById("dynamicSeatArea");

            if (idvoit && date) {
                seatArea.style.display = "block";
                // Appel au Servlet avec l'ID de réservation pour identifier nos propres places en bleu
                var url = "${pageContext.request.contextPath}/CheckPlacesServlet?idvoit=" + idvoit + "&date=" + date + "&idreserv=" + idreserv;
                
                fetch(url)
                    .then(response => response.text())
                    .then(data => {
                        document.getElementById("seatGridContainer").innerHTML = data;
                        
                        // Recalculer selectedSeats basé sur ce que le servlet a marqué comme 'selected-blue'
                        const preSelected = document.querySelectorAll('.selected-blue');
                        selectedSeats = Array.from(preSelected).map(s => {
                            const onclickAttr = s.getAttribute('onclick');
                            return parseInt(onclickAttr.match(/\d+/)[0]);
                        });
                        
                        updateDisplay();
                    });
            }
        }

        function selectSeat(element, num) {
            const index = selectedSeats.indexOf(num);
            if (index > -1) {
                // Décocher : Bleu -> Blanc
                selectedSeats.splice(index, 1);
                element.classList.remove('selected-blue');
                element.classList.add('available-white');
            } else {
                // Cocher : Blanc -> Bleu
                selectedSeats.push(num);
                element.classList.remove('available-white');
                element.classList.add('selected-blue');
            }
            updateDisplay();
        }

        function updateDisplay() {
            document.getElementById("inputPlace").value = selectedSeats.join(",");
            document.getElementById("displayPlaceNum").innerText = selectedSeats.length > 0 ? selectedSeats.join(", ") : "Aucune";
        }

        function validerModification(event) {
            const idVoit = document.getElementById("idvoitSelect").value;
            const prixUnitaire = voiturePrices[idVoit] || 0;
            const nbPlaces = selectedSeats.length;

            if (nbPlaces === 0) {
                event.preventDefault();
                Swal.fire({ title: 'Attention', text: 'Veuillez choisir au moins une place.', icon: 'warning' });
                return false;
            }

            const typePaiement = document.getElementById("payment").value;
            const avanceSaisie = parseInt(document.getElementById("montant_avance").value) || 0;
            const totalFrais = prixUnitaire * nbPlaces;

            if (typePaiement === "avec avance" && avanceSaisie > totalFrais) {
                event.preventDefault(); 
                Swal.fire({
                    title: 'Montant invalide',
                    text: 'L\'avance (' + avanceSaisie + ' Ar) ne peut pas dépasser le total (' + totalFrais + ' Ar).',
                    icon: 'error'
                });
                return false;
            }
            return true;
        }

        window.onload = function() {
            var today = new Date().toISOString().split('T')[0];
            document.getElementById("dateVoyage").setAttribute('min', today);
            toggleAvance();
            loadAvailableSeats();
        };
    </script>
</head>
<body>

<header class="main-header text-center shadow-sm">
    <div class="container">
        <h2 class="fw-bold text-uppercase m-0">COOPERATIVE DE TRANSPORT</h2>
        <p class="mb-2">MODIFICATION DE RÉSERVATION</p>
        <span class="id-badge"><i class="bi bi-hash"></i> RÉF : <%= (idreserv != null) ? idreserv : "NON DÉFINIE" %></span>
    </div>
</header>

<div class="container">
    <div class="form-card">
        <% if (reservation != null) { %>
        <form action="${pageContext.request.contextPath}/ReservationServlet" method="post" onsubmit="return validerModification(event)">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="idreserv" value="<%= reservation.getIdreserv() %>">

            <div class="mb-4">
                <label class="form-label"><i class="bi bi-person-fill"></i> Client associé</label>
                <select name="idcli" class="form-select shadow-sm" required>
                    <% for (Client c : clients) { %>
                        <option value="<%= c.getIdcli() %>" <%= (reservation.getIdcli() == c.getIdcli()) ? "selected" : "" %>>
                            <%= c.getNom().toUpperCase() %> (<%= c.getNumtel() %>)
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="row">
                <div class="col-md-6 mb-4">
                    <label class="form-label"><i class="bi bi-truck"></i> Véhicule</label>
                    <select name="idvoit" id="idvoitSelect" class="form-select shadow-sm" onchange="loadAvailableSeats()" required>
                        <% for (Voiture v : voitures) { %>
                            <option value="<%= v.getIdvoit() %>" <%= (reservation.getIdvoit().equals(v.getIdvoit())) ? "selected" : "" %>>
                                <%= v.getIdvoit() %> - <%= v.getDesign() %> (<%= v.getFrais() %> Ar/place)
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-6 mb-4">
                    <label class="form-label"><i class="bi bi-calendar-event"></i> Date du voyage</label>
                    <input type="date" name="date_voyage" id="dateVoyage" class="form-control shadow-sm" value="<%= reservation.getDateVoyage() %>" onchange="loadAvailableSeats()" required>
                </div>
            </div>

            <div id="dynamicSeatArea" class="mb-4">
                <label class="form-label text-primary"><i class="bi bi-grid-3x3-gap"></i> Plan de placement :</label>
                <div id="seatGridContainer" class="seat-grid shadow-inner"></div>
                
                <div class="d-flex gap-3 mt-2 mb-3 small">
                    <div><span class="badge" style="background-color: #fff; border: 1px solid #0d6efd; color:#000"> </span> Libre</div>
                    <div><span class="badge" style="background-color: #0d6efd;"> </span> Vos places</div>
                    <div><span class="badge" style="background-color: #e9ecef; border: 1px solid #dee2e6; color:#adb5bd"> </span> Autres clients</div>
                </div>

                <div class="mt-3 p-3 bg-light border-start border-primary border-4 rounded">
                    <span class="small text-muted text-uppercase fw-bold">Places après modification :</span>
                    <div id="displayPlaceNum" class="fw-bold text-primary fs-5 mt-1"><%= placesInitiales.toString() %></div>
                    <input type="hidden" name="place" id="inputPlace" value="<%= placesInitiales.toString() %>" required>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label"><i class="bi bi-cash-stack"></i> Statut Paiement</label>
                    <select name="payment" id="payment" class="form-select shadow-sm" onchange="toggleAvance()" required>
                        <option value="Sans avance" <%= reservation.getPayment().equalsIgnoreCase("Sans avance") ? "selected" : "" %>>Sans avance</option>
                        <option value="avec avance" <%= reservation.getPayment().equalsIgnoreCase("avec avance") ? "selected" : "" %>>Avec avance</option>
                        <option value="Tout payé" <%= reservation.getPayment().equalsIgnoreCase("Tout payé") ? "selected" : "" %>>Tout payé</option>
                    </select>
                </div>
                <div class="col-md-6 mb-3" id="avanceDiv">
                    <label class="form-label">Montant Avancé Global (Ar)</label>
                    <input type="number" name="montant_avance" id="montant_avance" class="form-control shadow-sm" value="<%= avanceCumulee %>">
                </div>
            </div>

            <button type="submit" class="btn-update shadow">
                <i class="bi bi-save-fill"></i> ENREGISTRER LES MODIFICATIONS
            </button>
        </form>
        <% } else { %>
            <div class="alert alert-danger text-center">
                <i class="bi bi-exclamation-triangle-fill"></i> Réservation introuvable.
            </div>
        <% } %>
        
        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/ReservationServlet?action=list" class="text-decoration-none text-muted fw-bold small">
                <i class="bi bi-arrow-left"></i> ANNULER ET RETOURNER
            </a>
        </div>
    </div>
</div>

<footer class="text-center">
    <div class="container"><strong>GESTION COOPÉRATIVE TRANSPORT &copy; 2026</strong></div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</body>
</html>