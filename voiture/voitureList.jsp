<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, model.Voiture, dao.VoitureDAO"%>
<%
    // On récupère la liste soit depuis le Servlet, soit directement via la DAO
    List<Voiture> voitures = (List<Voiture>) request.getAttribute("voitures");
    if (voitures == null) {
        VoitureDAO voitureDAO = new VoitureDAO();
        voitures = voitureDAO.getAll();
    }

    String currentPage="voitures";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des voitures - Gestion Cooperative</title>
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

        .search-input {
            border: 1px solid #ced4da;
            border-radius: 4px;
            padding: 12px 15px;
            width: 100%;
            max-width: 800px;
            display: block;
            margin: 0 auto;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.1);
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

        /* Styles pour le tableau - adaptés pour ne pas utiliser .table thead du CSS maison */
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
            display: inline-block;
        }

        .btn-action:hover {
            background-color: var(--primary-color);
            color: var(--white);
        }

        .btn-delete {
            border-color: #333;
            color: #333;
        }

        .btn-delete:hover {
            background-color: #dc3545;
            border-color: #dc3545;
            color: var(--white);
        }

        .nav-actions {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
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
        <input type="text" id="searchInput" class="search-input" placeholder="Filtrer par ID, Modèle, Type...">
    </div>
</section>

<div class="container content-wrapper">
    <div class="nav-actions">
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-main">Retour Accueil</a>
        <a href="${pageContext.request.contextPath}/voiture/voitureCreate.jsp" class="btn-main">Ajouter une voiture</a>
    </div>

    <div class="table-container">
        <div class="table-title">Liste du parc automobile</div>
        
        <table class="table table-hover" id="voitureTable">
            <thead>
                <tr>
                    <th>ID VOITURE</th>
                    <th>DESIGNATION</th>
                    <th>TYPE</th>
                    <th>PLACES</th>
                    <th>FRAIS (AR)</th>
                    <th>ACTIONS</th>
                </tr>
            </thead>
            <tbody>
                <% if (voitures != null) { 
                    for (Voiture v : voitures) { %>
                <tr>
                    <td><strong><%= v.getIdvoit() %></strong></td>
                    <td><%= v.getDesign() %></td>
                    <td style="text-transform: capitalize;"><%= v.getType() %></td>
                    <td><%= v.getNbrplace() %></td>
                    <td><%= String.format("%,d", v.getFrais()) %> Ar</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/voiture/voitureUpdate.jsp?id=<%= v.getIdvoit() %>" class="btn-action">Modifier</a>
                        <a href="javascript:void(0);" 
                           onclick="confirmerSuppressionVoiture('<%= v.getIdvoit() %>')" 
                           class="btn-action btn-delete">Supprimer</a>
                    </td>
                </tr>
                <% } } %>
            </tbody>
        </table>
    </div>
</div>

<footer class="text-center">
    <div class="container">
        GESTION DE RESERVATION DES PLACES DE COOPERATIVE
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="${pageContext.request.contextPath}/js/scripts.js"></script>

<script>
    // Filtrage dynamique
    document.getElementById('searchInput').addEventListener('keyup', function() {
        let filter = this.value.toLowerCase();
        let rows = document.querySelectorAll('#voitureTable tbody tr');
        rows.forEach(row => {
            let text = row.textContent.toLowerCase();
            row.style.display = text.includes(filter) ? '' : 'none';
        });
    });

    // Fonction de suppression adaptée à VoitureServlet
    function confirmerSuppressionVoiture(id) {
        Swal.fire({
            title: 'Supprimer ce véhicule ?',
            text: "Attention : toutes les places et réservations liées seront impactées !",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'OUI, SUPPRIMER',
            cancelButtonText: 'ANNULER'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = "${pageContext.request.contextPath}/VoitureServlet?action=delete&id=" + id;
            }
        });
    }
</script>

</body>
</html>