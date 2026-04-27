<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - Gestion Cooperative</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/App.css">
    <style>
        :root {
            --primary-color: #1a3a5f;
            --bg-color: #f8f9fa;
            --white: #ffffff;
            --text-dark: #333333;
            --accent-color: #ffc107;
        }

        body { 
            background-color: var(--bg-color);
            font-family: 'Segoe UI', Arial, sans-serif;
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Header */
        .main-header {
            background-color: var(--primary-color);
            color: var(--white);
            padding: 40px 0;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        /* Cartes Menu */
        .menu-card {
            background-color: var(--white);
            border: 1px solid #dee2e6;
            border-radius: 8px;
            text-align: center;
            transition: all 0.3s ease;
            text-decoration: none;
            color: var(--primary-color);
            display: flex;
            flex-direction: column;
            justify-content: center;
            height: 200px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .menu-card:hover {
            border-color: var(--primary-color);
            background-color: var(--primary-color);
            color: var(--white) !important;
            transform: translateY(-8px);
            box-shadow: 0 10px 20px rgba(26, 58, 95, 0.2);
        }

        .menu-card h3 {
            font-size: 1.5rem;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin: 0;
        }

        .menu-card span {
            font-size: 0.9rem;
            margin-top: 10px;
            opacity: 0.7;
        }

        /* Style spécial pour le bouton d'action rapide (Places) */
        .card-highlight {
            border: 2px dashed var(--primary-color);
            background-color: #fffdf5;
        }

        footer {
            padding: 25px 0;
            border-top: 1px solid #dee2e6;
            font-size: 0.85rem;
            color: #6c757d;
            background-color: var(--white);
            margin-top: auto;
        }
    </style>
</head>
<body>

<header class="main-header text-center">
    <div class="container">
        <h1 class="fw-bold">COOPERATIVE DE TRANSPORT</h1>
        <p class="lead mb-0">SYSTÈME DE GESTION DES RÉSERVATIONS</p>
    </div>
</header>

<div class="container my-auto py-5">
    <div class="row g-4 justify-content-center">
        
        <div class="col-md-6 col-lg-3">
            <a href="VoitureServlet" class="menu-card">
                <h3>Voitures</h3>
                <span>Choix de type</span>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="place/places.jsp" class="menu-card">
                <h3>Places</h3>
                <span>Disponibilités & Plan</span>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="ClientServlet" class="menu-card">
                <h3>Clients</h3>
                <span>Répertoire</span>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="ReservationServlet?action=list" class="menu-card">
                <h3>Réservations</h3>
                <span>Billetterie</span>
            </a>
        </div>
            
        <div class="col-md-6 col-lg-3">
    <a href="${pageContext.request.contextPath}/StatistiqueServlet" class="menu-card">
        <h3>Rapports</h3>
        <span>Recettes & Stats</span>
    </a>
</div>

    </div>
</div>

<footer class="text-center">
    <div class="container">
        <strong>GESTION DE RÉSERVATION DES PLACES DE COOPERATIVE</strong>
    </div>
</footer>

</body>
</html>