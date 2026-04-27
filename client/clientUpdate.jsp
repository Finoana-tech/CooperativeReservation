<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.ClientDAO, model.Client" %>
<%
    // On charge les donnees actuelles dans les champs
    ClientDAO dao = new ClientDAO();
    String idParam = request.getParameter("id");
    Client client = null;
    
    if (idParam != null) {
        try {
            int id = Integer.parseInt(idParam);
            client = dao.getById(id);
        } catch (Exception e) {
            client = null;
        }
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifier Client - Gestion Cooperative</title>
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

        .search-input-static {
            border: 1px solid #ced4da;
            border-radius: 4px;
            padding: 12px 20px;
            width: 100%;
            background-color: #fff;
            color: #999;
        }

        .content-wrapper {
            flex: 1;
        }

        .form-card {
            background-color: var(--white);
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 30px;
            max-width: 600px;
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
            display: block;
            margin-bottom: 5px;
        }

        .form-control {
            display: block;
            width: 100%;
            padding: 0.375rem 0.75rem;
            font-size: 1rem;
            font-weight: 400;
            line-height: 1.5;
            color: #212529;
            background-color: #fff;
            background-clip: padding-box;
            border: 1px solid #ced4da;
            border-radius: 0.375rem;
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
            margin-bottom: 20px;
        }

        .form-control:focus {
            color: #212529;
            background-color: #fff;
            border-color: #86b7fe;
            outline: 0;
            box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
        }

        .btn-update {
            background-color: var(--primary-color);
            color: var(--white);
            border: none;
            padding: 12px;
            width: 100%;
            font-weight: bold;
            text-transform: uppercase;
            cursor: pointer;
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
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-home">Retour a l'accueil</a>
        
        <div style="max-width: 800px; margin: 0 auto;">
            <div class="search-input-static">Recherche desactivee pendant la modification...</div>
        </div>
    </div>
</section>

<div class="container content-wrapper">
    <div class="form-card">
        <% if (client != null) { %>
            <div class="form-title text-center">Mise a jour du client : ID <%= client.getIdcli() %></div>
            
            <form action="${pageContext.request.contextPath}/ClientServlet" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="idcli" value="<%= client.getIdcli() %>">

                <div class="mb-3">
                    <label class="form-label">Nom complet</label>
                    <input type="text" name="nom" class="form-control" value="<%= client.getNom() %>" required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Numero de telephone</label>
                    <input type="tel" name="numtel" class="form-control" value="<%= client.getNumtel() %>" required>
                </div>

                <button type="submit" class="btn-update">Sauvegarder les modifications</button>
            </form>
        <% } else { %>
            <div class="alert alert-warning text-center">Client introuvable ou ID invalide.</div>
        <% } %>

        <a href="${pageContext.request.contextPath}/ClientServlet" class="back-action">ANNULER ET RETOURNER A LA LISTE</a>
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