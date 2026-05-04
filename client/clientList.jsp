<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Client"%>
<%
    // On récupère la liste envoyée par le Servlet (ClientServlet)
    List<Client> clients = (List<Client>) request.getAttribute("clients");
    
    // Sécurité : si on accède à la page sans passer par le servlet, on évite l'erreur null
    if (clients == null) {
        clients = new ArrayList<>();
    }

    String currentPage="clients";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des clients - Gestion Cooperative</title>
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
        }

        .search-input {
            border: 1px solid #ced4da;
            border-radius: 4px;
            padding: 12px 20px;
            width: 100%;
            font-weight: 500;
        }

        .content-wrapper {
            flex: 1;
            margin-bottom: 40px;
        }

        .table-container {
            background-color: var(--white);
            border: 1px solid #dee2e6;
            padding: 20px;
            border-radius: 4px;
        }

        .table-container .table thead th {
            background-color: var(--primary-color);
            color: var(--white);
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

        .btn-action {
            text-decoration: none;
            font-size: 0.8rem;
            font-weight: bold;
            text-transform: uppercase;
            padding: 5px 10px;
            border: 1px solid var(--primary-color);
            color: var(--primary-color);
            margin-right: 5px;
            background: transparent;
            display: inline-block;
        }

        .btn-delete {
            border-color: #333;
            color:#333;
        }
        .btn-action:hover {
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
            display: inline-block;
        }
        .btn-main:hover { color: white; opacity: 0.9; }

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
    <jsp:include page="../includes/header.jsp" />
</header>

<section class="search-bar-container">
    <div class="container">
        <div class="search-form">
            <input type="text" id="searchInput" class="search-input" style="font-size:15px;" placeholder="Rechercher un client par son nom ou par son telephone...">
        </div>
    </div>
</section>

<div class="container content-wrapper">
    <div class="d-flex justify-content-between mb-4">
        <a href="client/clientCreate.jsp" class="btn-main">Nouveau Client</a>
    </div>

    <div class="table-container">
        <div class="table-title">Base de donnees Clients</div>
        
        <table class="table table-hover" id="clientTable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>NOM COMPLET</th>
                    <th>TELEPHONE</th>
                    <th>ACTIONS</th>
                </tr>
            </thead>
            <tbody>
                <% for (Client c : clients) { %>
                <tr class="client-row">
                    <td><%= c.getIdcli() %></td>
                    <td class="client-name"><%= c.getNom() %></td>
                    <td class="client-phone"><%= c.getNumtel() %></td>
                    <td>
                        <a href="client/clientUpdate.jsp?id=<%= c.getIdcli() %>" class="btn-action">Modifier</a>
                        
                        <a href="javascript:void(0);" 
                           class="btn-action border-danger" 
                           onclick="confirmerSuppression('<%= c.getIdcli() %>', '<%= c.getNom() %>', '${pageContext.request.contextPath}/ClientServlet')">
                           Supprimer
                        </a>
                    </td>
                </tr>
                <% } %>
                <% if (clients.isEmpty()) { %>
                <tr>
                    <td colspan="4" class="text-center text-muted">Aucun client trouve.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<footer class="main-footer">
    <div class="header-container">
        <p>&copy; 2026 COOPERATIVE DE TRANSPORT - Tous droits réservés</p>
        <p style="font-size: 0.75rem; margin-top: 5px;">Système de gestion des réservations de places</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="${pageContext.request.contextPath}/js/scripts.js"></script>

<script>
// Recherche dynamique
document.getElementById('searchInput').addEventListener('keyup', function() {
    let filter = this.value.toLowerCase();
    let rows = document.querySelectorAll('.client-row');

    rows.forEach(row => {
        let name = row.querySelector('.client-name').textContent.toLowerCase();
        let phone = row.querySelector('.client-phone').textContent.toLowerCase();
        
        if (name.includes(filter) || phone.includes(filter)) {
            row.style.display = "";
        } else {
            row.style.display = "none";
        }
    });
});
</script>

</body>
</html>