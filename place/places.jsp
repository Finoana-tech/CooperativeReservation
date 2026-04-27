<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.*, dao.*" %>
<%
    // Récupération de la liste des voitures pour alimenter le menu déroulant
    VoitureDAO voitDAO = new VoitureDAO();
    List<Voiture> listeVoitures = voitDAO.getAll();
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultation des Places - Coopérative</title>
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
        }

        .main-header {
            background-color: var(--primary-color);
            color: var(--white);
            padding: 25px 0;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        /* AJUSTEMENT : On retire grid-template-columns fixe pour laisser le Flex/Grid s'adapter 
           aux rectangles de 75px générés par le Servlet */
        #seatGrid {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 10px;
            background: #ffffff;
            padding: 25px;
            border-radius: 10px;
            border: 1px solid #dee2e6;
            margin-top: 20px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
        }
        .box {
            width: 25px;
            height: 20px;
            border-radius: 4px;
        }

        footer {
            padding: 20px 0;
            border-top: 1px solid #dee2e6;
            background-color: var(--white);
            margin-top: auto;
        }
    </style>
</head>
<body>

<header class="main-header text-center">
    <div class="container">
        <h1 class="fw-bold h3 mb-0">COOPERATIVE DE TRANSPORT</h1>
        <p class="small mb-0 opacity-75">CONSULTATION DES DISPONIBILITÉS</p>
    </div>
</header>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-9">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3 border-bottom">
                    <h5 class="mb-0 text-primary">Visualisation du plan de voyage</h5>
                </div>
                <div class="card-body">
                    
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold small text-muted text-uppercase">Véhicule</label>
                            <select id="idvoit" class="form-select" onchange="chargerPlaces()">
                                <option value="">-- Choisir une voiture --</option>
                                <% for(Voiture v : listeVoitures) { %>
                                    <option value="<%= v.getIdvoit() %>">
                                        <%= v.getDesign() %> (<%= v.getType() %>)
                                    </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold small text-muted text-uppercase">Date de départ</label>
                            <input type="date" id="dateVoyage" class="form-control" onchange="chargerPlaces()">
                        </div>
                    </div>

                    <hr class="my-4">

                    <div class="d-flex justify-content-center flex-wrap gap-4 mb-3">
                        <div class="legend-item">
                            <div class="box" style="background-color: #ffffff; border: 2px solid #1a3a5f;"></div>
                            <span class="fw-semibold">Libre</span>
                        </div>
                        <div class="legend-item">
                            <div class="box" style="background-color: #e9ecef; border: 1px solid #dee2e6;"></div>
                            <span class="fw-semibold">Occupé</span>
                        </div>
                    </div>

                    <div id="seatGrid" style="display: none;"></div>

                    <div id="emptyMessage" class="text-center text-muted py-5">
                        <div class="fs-1 opacity-25">📋</div>
                        <p class="mt-2">Veuillez sélectionner les critères pour afficher les places disponibles.</p>
                    </div>

                </div>
            </div>
            
            <div class="mt-4 text-start">
                <a href="../index.jsp" class="btn-secondary shadow-sm">
                     Retour au Menu
                </a>
            </div>
        </div>
    </div>
</div>

<footer class="text-center">
    <div class="container">
        <small class="text-muted fw-bold">SYSTÈME DE GESTION COOPÉRATIVE  2026</small>
    </div>
</footer>

<script>
function chargerPlaces() {
    const idvoit = document.getElementById("idvoit").value;
    const date = document.getElementById("dateVoyage").value;
    const grid = document.getElementById("seatGrid");
    const msg = document.getElementById("emptyMessage");

    if (idvoit !== "" && date !== "") {
        msg.style.display = "none";
        grid.style.display = "flex";
        
        grid.innerHTML = `
            <div class="text-center w-100 py-5">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="mt-3 text-muted">Récupération du plan en cours...</p>
            </div>`;

        fetch(`../CheckPlacesServlet?idvoit=\${encodeURIComponent(idvoit)}&date=\${encodeURIComponent(date)}`)
            .then(response => {
                if(!response.ok) throw new Error("Erreur serveur");
                return response.text();
            })
            .then(html => {
                if(!html || html.trim() === "") {
                    grid.innerHTML = "<div class='alert alert-warning w-100 m-0'>Aucune place trouvée pour ce véhicule.</div>";
                } else {
                    grid.innerHTML = html;
                    
                    const seats = grid.querySelectorAll('.seat');
                    seats.forEach(s => {
                        s.onclick = null; 
                        s.style.cursor = "default";
                    });
                }
            })
            .catch(err => {
                grid.innerHTML = "<div class='alert alert-danger w-100'>Erreur de connexion au serveur.</div>";
                console.error(err);
            });
    } else {
        grid.style.display = "none";
        msg.style.display = "block";
    }
}
</script>

</body>
</html>