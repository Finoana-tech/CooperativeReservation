<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = "accueil";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - Gestion Cooperative</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/App.css">
    <style>
        .welcome-message {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .welcome-message h2 {
            color: var(--primary-color, #1a3a5f);
            font-size: 1.8rem;
            margin-bottom: 10px;
        }
        
        .welcome-message p {
            color: #6c757d;
            font-size: 1rem;
        }
        
        .custom-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

    </style>
</head>
<body>

<!-- Inclusion du header -->
<jsp:include page="/includes/header.jsp" />

<!-- Contenu principal -->
<div class="content-wrapper">
    <div class="custom-container">
        
        <div class="welcome-message">
            <h2>Bienvenue dans votre espace de gestion</h2>
            <p>Sélectionnez un module pour commencer</p>
        </div>
        
        <div class="row g-4 justify-content-center">
            
            <div class="col-md-6 col-lg-3">
                <a href="VoitureServlet" class="menu-card">
                    <div class="menu-icon">
                        <img src="${pageContext.request.contextPath}/icons/voiture_management.svg" alt="voiture" class="icon">
                    </div>
                    <h3>Voitures</h3>
                    <span>Gestion du parc automobile</span>
                </a>
            </div>

            <div class="col-md-6 col-lg-3">
                <a href="place/places.jsp" class="menu-card">
                    <div class="menu-icon">
                        <img src="${pageContext.request.contextPath}/icons/place_management.svg" alt="place" class="icon">
                    </div>
                    <h3>Places</h3>
                    <span>Disponibilités & Plan</span>
                </a>
            </div>

            <div class="col-md-6 col-lg-3">
                <a href="ClientServlet" class="menu-card">
                    <div class="menu-icon">
                        <img src="${pageContext.request.contextPath}/icons/client_management.svg" alt="client" class="icon">
                    </div>
                    <h3>Clients</h3>
                    <span>Répertoire complet</span>
                </a>
            </div>

            <div class="col-md-6 col-lg-3">
                <a href="ReservationServlet?action=list" class="menu-card">
                    <div class="menu-icon">
                        <img src="${pageContext.request.contextPath}/icons/reservation_management.svg" alt="réservation" class="icon">
                    </div>
                    <h3>Réservations</h3>
                    <span>Billetterie & suivi</span>
                </a>
            </div>
                
            <div class="col-md-6 col-lg-3">
                <a href="${pageContext.request.contextPath}/StatistiqueServlet" class="menu-card">
                    <div class="menu-icon">
                        <img src="${pageContext.request.contextPath}/icons/stat_management.svg" alt="statistiques" 
                             class="icon"  >
                    </div>
                    <h3>Rapports</h3>
                    <span>Recettes & Statistiques</span>
                </a>
            </div>

        </div>
    </div>
</div>

<footer class="main-footer">
    <div class="header-container">
        <p>&copy; 2026 COOPERATIVE DE TRANSPORT - Tous droits réservés</p>
        <p style="font-size: 0.75rem; margin-top: 5px;">Système de gestion des réservations de places</p>
    </div>
</footer>

</body>
</html>