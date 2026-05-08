<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Reservation, model.Client, model.Voiture, dao.ClientDAO, dao.VoitureDAO, dao.ReservationDAO"%>
<%
    // 1. Récupération des données envoyées par le Servlet
    List<Reservation> reservationsBrutes = (List<Reservation>) request.getAttribute("reservations");
    Integer recetteTotale = (Integer) request.getAttribute("recetteTotale");

    // 2. SÉCURITÉ : Si la page est appelée sans données (ex: accès direct ou après ajout)
    // On force le chargement depuis la base de données via la DAO
    if (reservationsBrutes == null) {
        ReservationDAO resDAO = new ReservationDAO();
        reservationsBrutes = resDAO.getAll(); 
    }
    
    if (recetteTotale == null) {
        ReservationDAO resDAO = new ReservationDAO();
        recetteTotale = resDAO.getRecetteTotale();
    }

    // --- LOGIQUE DE REGROUPEMENT PAR IDRESERV (Indispensable pour vos lignes groupées) ---
    Map<String, Reservation> groupeMap = new LinkedHashMap<>();
    Map<String, List<Integer>> placesMap = new HashMap<>();
    Map<String, Integer> avanceTotaleMap = new HashMap<>();

    for (Reservation r : reservationsBrutes) {
        String id = r.getIdreserv(); 
        if (!groupeMap.containsKey(id)) {
            groupeMap.put(id, r);
            placesMap.put(id, new ArrayList<>());
            avanceTotaleMap.put(id, 0);
        }
        placesMap.get(id).add(r.getPlace());
        avanceTotaleMap.put(id, avanceTotaleMap.get(id) + r.getMontantAvance());
    }

    ClientDAO clientDAO = new ClientDAO();
    VoitureDAO voitureDAO = new VoitureDAO();

    String currentPage ="reservations";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Journal des Réservations - Gestion Coopérative</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/App.css">
    <style>
        :root { 
            --primary-color: #1a3a5f; 
            --bg-color: #f8f9fa; 
            --white: #ffffff; 
            --text-dark: #333333;
        }
        
        body { 
            background-color: var(--bg-color); 
            font-family: 'Segoe UI', Arial, sans-serif; 
            color: var(--text-dark);
            min-height: 100vh; 
            display: flex; 
            flex-direction: column; 
            padding-top: 20px;
        }

        .main-header { 
            background-color: var(--primary-color); 
            color: var(--white); 
            padding: 30px 0; 
        }


        .content-wrapper { flex: 1; margin-bottom: 40px;  padding-top:60px; }

        .table-container { 
            background: var(--white); 
            border: 1px solid #dee2e6; 
            border-radius: 4px; 
            padding-top: 25px; 
        }
        
        .table-title { 
            color: var(--primary-color); 
            font-weight: bold; 
            text-transform: uppercase; 
            border-bottom: 2px solid var(--primary-color); 
            padding-bottom: 10px; 
            margin-bottom: 20px; 
            font-size: 1.1rem; 
        }
        
        .table-container .table thead th {
            background-color: var(--primary-color);
            color: var(--white);
        }

        .btn-main { 
            background-color: var(--primary-color); 
            color: var(--white); 
            text-decoration: none; 
            padding: 10px 20px; 
            font-weight: bold; 
            text-transform: uppercase; 
            font-size: 0.85rem; 
            border-radius: 4px; 
            border: none;
            display: inline-block;
            cursor: pointer;
        }
        .btn-main:hover { color: white; opacity: 0.9; }

        .btn-action { 
            text-decoration: none; 
            font-size: 0.75rem; 
            font-weight: bold; 
            text-transform: uppercase; 
            padding: 5px 10px; 
            border: 1px solid var(--primary-color); 
            color: var(--primary-color); 
            background: transparent;
            margin-bottom: 2px;
            display: inline-block;
        }
        .btn-action:hover { background-color: var(--primary-color); color: var(--white); }
        
        .btn-delete { border-color: #333; color: #333; }
        .btn-delete:hover { background-color: #dc3545; border-color: #dc3545; color: var(--white); }

        .badge-place { 
            font-size: 0.8rem; 
            background-color: #f1f3f5; 
            color: var(--primary-color); 
            border: 1px solid #dee2e6; 
            padding: 2px 6px; 
            border-radius: 3px; 
            margin: 1px;
            display: inline-block;
        }

        footer { 
            padding: 20px 0; 
            border-top: 1px solid #dee2e6; 
            font-size: 0.8rem; 
            color: #6c757d; 
            background: var(--white); 
        }
    </style>
</head>
<body>

<jsp:include page="../includes/header.jsp" />

<div class="container content-wrapper">
    <div class="d-flex justify-content-between mb-4">
        <a href="<%= request.getContextPath() %>/reservation/reservationCreate.jsp" class="btn-main">Nouvelle Réservation</a>
    </div>

    <div class="table-container shadow-sm">
        <div class="table-title">Liste des réservations</div>
        
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>RÉFÉRENCE</th>
                        <th>CLIENT</th>
                        <th>VÉHICULE</th>
                        <th class="text-center">PLACES</th>
                        <th>DATE VOYAGE</th>
                        <th>PAIEMENT</th>
                        <th class="text-end">AVANCE</th>
                        <th class="text-center">ACTIONS</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (groupeMap.isEmpty()) { %>
                        <tr><td colspan="8" class="text-center py-4 text-muted">Aucune réservation enregistrée.少数</td></tr>
                    <% } %>
                    
                    <% 
                    for (String idRes : groupeMap.keySet()) { 
                        Reservation r = groupeMap.get(idRes);
                        List<Integer> listPlaces = placesMap.get(idRes);
                        int avanceCumulee = avanceTotaleMap.get(idRes);
                        
                        Client client = clientDAO.getById(r.getIdcli());
                        Voiture voiture = voitureDAO.getById(r.getIdvoit());
                        Collections.sort(listPlaces);
                    %>
                    <tr>
                        <td><strong><%= r.getIdreserv() %></strong></td>
                        <td>
                            <div class="fw-bold"><%= client != null ? client.getNom() : "Client #" + r.getIdcli() %></div>
                            <small class="text-muted"><%= client != null ? client.getNumtel() : "" %></small>
                        </td>
                        <td>
                            <span class="text-primary fw-bold"><%= r.getIdvoit() %></span><br>
                            <small><%= voiture != null ? voiture.getDesign() : "" %></small>
                        </td>
                        <td class="text-center">
                            <% for(Integer p : listPlaces) { %>
                                <span class="badge-place">N°<%= p %></span>
                            <% } %>
                        </td>
                        <td><%= r.getDateVoyage() %></td>
                        <td>
                            <span class="small fw-bold text-uppercase">
                                <%= r.getPayment() %>
                            </span>
                        </td>
                        <td class="text-end fw-bold"><%= String.format("%,d", avanceCumulee) %> Ar</td>
                        <td class="text-center">
                            <a href="<%= request.getContextPath() %>/BilletPdfServlet?id=<%= r.getIdreserv() %>" class="btn-action" target="_blank">Billet</a>
                            <a href="<%= request.getContextPath() %>/reservation/reservationUpdate.jsp?id=<%= r.getIdreserv() %>" class="btn-action">Modifier</a>
                            <a href="javascript:void(0);" onclick="confirmerSuppression('<%= r.getIdreserv() %>', 'ReservationServlet')" class="btn-action btn-delete">Annuler</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<footer class="main-footer">
    <div class="header-container">
        <p>&copy; 2026 COOPERATIVE DE TRANSPORT - Tous droits réservés</p>
        <p style="font-size: 0.75rem; margin-top: 5px;">Système de gestion des réservations de places</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    function confirmerSuppression(id, servlet) {
        Swal.fire({
            title: 'Annuler la réservation ?',
            text: "La référence " + id + " sera définitivement supprimée.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#1a3a5f',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'OUI, ANNULER',
            cancelButtonText: 'RETOUR'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = "<%= request.getContextPath() %>/" + servlet + "?action=delete&id=" + id;
            }
        })
    }
</script>

</body>
</html>