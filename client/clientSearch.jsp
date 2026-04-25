<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Client, dao.ClientDAO"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Rechercher un client</title>
    <style>
        .container { width: 80%; margin: 20px auto; }
        .search-box { text-align: center; margin: 20px; }
        input[type="text"] { padding: 10px; width: 300px; border: 1px solid #ddd; border-radius: 5px; }
        input[type="submit"] { padding: 10px 20px; background-color: #2196F3; color: white; border: none; border-radius: 5px; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #2196F3; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h2 style="text-align:center">🔍 Rechercher un client</h2>
        
        <div class="search-box">
            <form method="get">
                <input type="text" name="motCle" placeholder="Nom ou numéro de téléphone..." value="<%= request.getParameter("motCle") != null ? request.getParameter("motCle") : "" %>">
                <input type="submit" value="Rechercher">
            </form>
        </div>
        
        <% 
            String motCle = request.getParameter("motCle");
            if (motCle != null && !motCle.trim().isEmpty()) {
                ClientDAO dao = new ClientDAO();
                List<Client> clients = dao.rechercher(motCle);
        %>
            <h3>Résultats pour : "<%= motCle %>" (<%= clients.size() %> client(s))</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nom</th>
                        <th>Téléphone</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Client c : clients) { %>
                    <tr>
                        <td><%= c.getIdcli() %></td>
                        <td><%= c.getNom() %></td>
                        <td><%= c.getNumtel() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
        
        <div style="margin-top: 20px; text-align:center">
            <a href="liste.jsp">📋 Liste des clients</a> |
            <a href="../index.jsp">🏠 Accueil</a>
        </div>
    </div>
</body>
</html>