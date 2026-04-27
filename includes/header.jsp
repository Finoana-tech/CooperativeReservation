<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 
    Fichier header à inclure dans toutes les pages
    Variable attendue : currentPage (accueil, voitures, places, clients, reservations, rapports)
--%>

<%-- IMPORT DU CSS DÉDIÉ AU HEADER --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/styles/header.css">

<header class="main-header">
    <div class="header-container">
        
        <!-- LOGO À GAUCHE -->
        <div class="logo-wrapper">
            <!--<div class="logo-icon">
                <img src="${pageContext.request.contextPath}/icons/logo.svg" alt="Logo" class="icon" width="28" height="28">
            </div>-->
            <div class="logo-text">
                <h1>COOPERATIVE DE TRANSPORT</h1>
            </div>
        </div>
        
        <!-- MENU À DROITE -->
        <nav class="nav-bar">
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="nav-link ${currentPage == 'accueil' ? 'active' : ''}">
                        <div class="menu-icon">
                            <img src="${pageContext.request.contextPath}/icons/home_page.svg" alt="Accueil" class="icon">
                        </div>
                        <span class="nav-text">Accueil</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/VoitureServlet" class="nav-link ${currentPage == 'voitures' ? 'active' : ''}">
                        <div class="menu-icon">
                            <img src="${pageContext.request.contextPath}/icons/voiture_management.svg" alt="Voitures" class="icon">
                        </div>
                        <span class="nav-text">Voitures</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/place/places.jsp" class="nav-link ${currentPage == 'places' ? 'active' : ''}">
                        <div class="menu-icon">
                            <img src="${pageContext.request.contextPath}/icons/place_management.svg" alt="Places" class="icon">
                        </div>
                        <span class="nav-text">Places</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/ClientServlet" class="nav-link ${currentPage == 'clients' ? 'active' : ''}">
                        <div class="menu-icon">
                            <img src="${pageContext.request.contextPath}/icons/client_management.svg" alt="Clients" class="icon">
                        </div>
                        <span class="nav-text">Clients</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/ReservationServlet?action=list" class="nav-link ${currentPage == 'reservations' ? 'active' : ''}">
                        <div class="menu-icon">
                            <img src="${pageContext.request.contextPath}/icons/reservation_management.svg" alt="Réservations" class="icon">
                        </div>
                        <span class="nav-text">Réservations</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/StatistiqueServlet" class="nav-link ${currentPage == 'rapports' ? 'active' : ''}">
                        <div class="menu-icon">
                            <img src="${pageContext.request.contextPath}/icons/stat_management.svg" alt="Rapports" class="icon">
                        </div>
                        <span class="nav-text">Rapports</span>
                    </a>
                </li>
            </ul>
        </nav>
        
    </div>
</header>

<script>
    // Ajuste automatiquement le padding-top en fonction de la hauteur du header
    function adjustHeaderMargin() {
        var header = document.querySelector('.main-header');
        if (header) {
            var headerHeight = header.offsetHeight;
            document.body.style.paddingTop = headerHeight + 'px';
        }
    }
    
    // Exécuter au chargement et au redimensionnement
    window.addEventListener('load', adjustHeaderMargin);
    window.addEventListener('resize', adjustHeaderMargin);
</script>