<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.VoitureDAO, model.Voiture" %>
<%
    // On récupère la voiture à modifier via la DAO pour remplir le formulaire
    VoitureDAO dao = new VoitureDAO();
    String id = request.getParameter("id");
    Voiture voiture = dao.getById(id);
    
    // Si la voiture n'existe pas, on redirige avec un message d'erreur clair
    if (voiture == null) {
        response.sendRedirect(request.getContextPath() + "/VoitureServlet?msg=Erreur : Vehicule introuvable");
        return;
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifier Voiture - Gestion Cooperative</title>
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
            padding: 30px 0;
        }

        .search-bar-container {
            background-color: #e9ecef;
            padding: 20px 0;
            border-bottom: 1px solid #dee2e6;
            margin-bottom: 30px;
        }

        .btn-home {
            background-color: #6c757d;
            color: var(--white);
            text-decoration: none;
            padding: 8px 15px;
            font-weight: bold;
            text-transform: uppercase;
            font-size: 0.8rem;
            display: inline-block;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .btn-home:hover { color: white; opacity: 0.9; }

        .content-wrapper {
            flex: 1;
        }

        .form-card {
            background-color: var(--white);
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 30px;
            max-width: 700px;
            margin: 0 auto 40px auto;
        }

        .form-title {
            color: var(--primary-color);
            font-weight: bold;
            text-transform: uppercase;
            border-bottom: 2px solid var(--primary-color);
            padding-bottom: 10px;
            margin-bottom: 25px;
            font-size: 1.1rem;
        }

        .form-label {
            font-weight: bold;
            font-size: 0.85rem;
            color: #555;
            text-transform: uppercase;
        }

        .form-control, .form-select {
            border-radius: 4px;
            margin-bottom: 15px;
        }

        .btn-update {
            background-color: var(--primary-color);
            color: var(--white);
            border: none;
            padding: 12px;
            width: 100%;
            font-weight: bold;
            text-transform: uppercase;
            margin-top: 10px;
            border-radius: 4px;
        }
        .btn-update:hover { opacity: 0.9; }

        .back-action {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: bold;
        }

        footer {
            padding: 20px 0;
            border-top: 1px solid #dee2e6;
            font-size: 0.8rem;
            color: #6c757d;
            background-color: var(--white);
        }
    </style>
</head>
<body>

<header class="main-header text-center">
    <div class="container">
        <h1>COOPERATIVE DE TRANSPORT</h1>
        <p>SYSTEME DE GESTION DES RESERVATIONS</p>
    </div>
</header>

<section class="search-bar-container">
    <div class="container text-center">
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-home">Retour à l'accueil</a>
        
        <form action="${pageContext.request.contextPath}/VoitureServlet" method="GET" class="mx-auto" style="max-width: 600px;">
            <div class="input-group">
                <input type="text" name="search" class="form-control" placeholder="Rechercher une voiture...">
                <button type="submit" class="btn-main text-uppercase fw-bold">Rechercher</button>
            </div>
        </form>
    </div>
</section>

<div class="container content-wrapper">
    <div class="form-card">
        <div class="form-title text-center">Modification du véhicule : <%= voiture.getIdvoit() %></div>
        
        <form action="${pageContext.request.contextPath}/VoitureServlet" method="post">
            <%-- Champ caché pour définir l'action update --%>
            <input type="hidden" name="action" value="update">
            <%-- Identifiant non modifiable envoyé au servlet --%>
            <input type="hidden" name="idvoit" value="<%= voiture.getIdvoit() %>">

            <div class="mb-3">
                <label class="form-label">Désignation du modèle</label>
                <input type="text" name="design" class="form-control" value="<%= voiture.getDesign() %>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Type de service</label>
                <select name="type" class="form-select">
                    <option value="simple" <%= "simple".equals(voiture.getType()) ? "selected" : "" %>>Simple</option>
                    <option value="premium" <%= "premium".equals(voiture.getType()) ? "selected" : "" %>>Premium</option>
                    <option value="VIP" <%= "VIP".equals(voiture.getType()) ? "selected" : "" %>>VIP</option>
                </select>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Nombre de places</label>
                    <input type="number" name="nbrplace" class="form-control" value="<%= voiture.getNbrplace() %>" min="1" required>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">Frais de voyage (Ar)</label>
                    <input type="number" name="frais" class="form-control" value="<%= voiture.getFrais() %>" min="0" required>
                </div>
            </div>

            <button type="submit" class="btn-update">Enregistrer les modifications</button>
        </form>

        <a href="${pageContext.request.contextPath}/VoitureServlet" class="back-action">ANNULER ET RETOURNER A LA LISTE</a>
    </div>
</div>

<footer class="text-center">
    <div class="container">
        GESTION DE RESERVATION DES PLACES DE COOPERATIVE
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="${pageContext.request.contextPath}/js/scripts.js"></script>

</body>
</html>