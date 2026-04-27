<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% 
    String currentPage="clients";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ajouter Client - Gestion Cooperative</title>
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

        .search-form {
            max-width: 800px;
            margin: 0 auto;
            display: flex;
            gap: 10px;
        }

        .search-input {
            border: 1px solid #ced4da;
            border-radius: 4px;
            padding: 10px 15px;
            flex-grow: 1;
        }

        .btn-search {
            background-color: var(--primary-color);
            color: var(--white);
            border: none;
            padding: 10px 25px;
            border-radius: 4px;
            text-transform: uppercase;
            font-weight: bold;
            cursor: pointer;
        }
        .btn-search:hover {
            opacity: 0.9;
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

        .btn-validate {
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
        .btn-validate:hover { opacity: 0.9; }

        .btn-home {
            background-color: #6c757d;
            color: var(--white);
            text-decoration: none;
            padding: 10px 20px;
            font-weight: bold;
            text-transform: uppercase;
            font-size: 0.85rem;
            display: inline-block;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .btn-home:hover { color: white; opacity: 0.9; }

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

<jsp:include page="../includes/header.jsp" />
<section class="search-bar-container">
    <div class="container text-center">
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-home">Retour a l'accueil</a>
        
        <form action="${pageContext.request.contextPath}/ClientServlet" method="GET" class="search-form">
            <input type="text" name="search" class="search-input" placeholder="Rechercher un client par son nom ou numero de telephone...">
            <button type="submit" class="btn-search">Rechercher</button>
        </form>
    </div>
</section>

<div class="container content-wrapper">
    <div class="form-card">
        <div class="form-title text-center">Enregistrement d'un nouveau client</div>
        
        <form action="${pageContext.request.contextPath}/ClientServlet" method="POST">
            <input type="hidden" name="action" value="create">

            <div class="mb-3">
                <label class="form-label">Nom complet du client</label>
                <input type="text" name="nom" class="form-control" placeholder="Saisir le nom et prenom" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Numero de telephone</label>
                <input type="tel" name="numtel" class="form-control" placeholder="Ex: 034 00 000 00" required>
            </div>

            <button type="submit" class="btn-validate">Enregistrer le client</button>
        </form>

        <a href="${pageContext.request.contextPath}/ClientServlet" class="back-action">RETOUR A LA LISTE DES CLIENTS</a>
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