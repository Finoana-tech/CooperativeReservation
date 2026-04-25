<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.ClientDAO, model.Client" %>
<%
    // On récupère l'ID pour afficher à qui appartient la suppression
    String idParam = request.getParameter("id");
    Client client = null;
    if (idParam != null) {
        try {
            ClientDAO dao = new ClientDAO();
            client = dao.getById(Integer.parseInt(idParam));
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
    <title>Confirmer Suppression - Gestion Cooperative</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1a3a5f;
            --bg-color: #f8f9fa;
            --danger-color: #dc3545;
        }
        body { 
            background-color: var(--bg-color); 
            font-family: 'Segoe UI', sans-serif; 
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .main-header { background-color: var(--primary-color); color: white; padding: 20px 0; }
        .confirm-card {
            background: white;
            border-radius: 8px;
            border: 1px solid #dee2e6;
            max-width: 500px;
            margin: 50px auto;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .btn-confirm { background-color: var(--danger-color); color: white; font-weight: bold; text-transform: uppercase; border: none; }
        .btn-confirm:hover { background-color: #a71d2a; color: white; }
        .btn-cancel { background-color: #6c757d; color: white; font-weight: bold; text-transform: uppercase; border: none; }
        .btn-cancel:hover { background-color: #5a6268; color: white; }
        
        .btn-home {
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            padding: 8px 15px;
            font-weight: bold;
            border-radius: 4px;
            font-size: 0.8rem;
            display: inline-block;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<header class="main-header text-center">
    <div class="container">
        <h1>ATTENTION : SUPPRESSION</h1>
    </div>
</header>

<div class="container text-center mt-4">
    <a href="../index.jsp" class="btn-home">Retour à l'accueil</a>
</div>

<div class="container">
    <div class="confirm-card text-center">
        <% if (client != null) { %>
            <div class="mb-4">
                <span style="font-size: 3rem;">⚠️</span>
                <h3 class="mt-3">Confirmer la suppression ?</h3>
                <p class="text-muted">Vous êtes sur le point de supprimer le client suivant :</p>
                <div class="alert alert-light border">
                    <strong><%= client.getNom() %></strong><br>
                    <small>Téléphone : <%= client.getNumtel() %></small>
                </div>
                <p class="text-danger small fw-bold">Cette action est irréversible.</p>
            </div>

            <div class="d-grid gap-2">
                <%-- Lien de suppression directe --%>
                <a href="../ClientServlet?action=delete&idcli=<%= client.getIdcli() %>" class="btn btn-confirm p-3">
                    Oui, Supprimer définitivement
                </a>
                <a href="../ClientServlet" class="btn btn-cancel p-2 text-decoration-none">
                    Annuler
                </a>
            </div>
        <% } else { %>
            <div class="alert alert-warning">Client introuvable.</div>
            <a href="../ClientServlet" class="btn btn-secondary">Retour à la liste</a>
        <% } %>
    </div>
</div>

<footer class="text-center mt-auto py-3 border-top bg-white text-muted" style="font-size: 0.8rem;">
    <div class="container">
        GESTION DE RESERVATION DES PLACES DE COOPERATIVE
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="${pageContext.request.contextPath}/scripts.js"></script>

</body>
</html>