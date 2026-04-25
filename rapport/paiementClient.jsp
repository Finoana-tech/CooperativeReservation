<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, util.DatabaseConnection" %>
<%
    Connection conn = DatabaseConnection.getConnection();
    String selectedId = request.getParameter("idvoit");
    
    // Requête pour les voitures (Filtre)
    Statement stmt = conn.createStatement();
    ResultSet rsVoitures = stmt.executeQuery("SELECT idvoit, Design FROM VOITURE");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Suivi des Paiements - Cooperative</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root { --primary-color: #1a3a5f; --bg-color: #f8f9fa; }
        body { background-color: var(--bg-color); font-family: 'Segoe UI', sans-serif; }
        .main-header { background-color: var(--primary-color); color: white; padding: 30px 0; margin-bottom: 20px; }
        .section-title { 
            border-left: 5px solid var(--primary-color); 
            padding-left: 15px; 
            margin: 30px 0 15px 0; 
            font-weight: bold; 
            text-transform: uppercase;
            font-size: 1.1rem;
        }
        .table { background: white; border-radius: 4px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .thead-dark { background-color: var(--primary-color); color: white; }
        .card-summary { background: white; border: 1px solid #dee2e6; padding: 20px; border-radius: 4px; }
        .btn-filter { background-color: var(--primary-color); color: white; font-weight: bold; }
        .badge-status { font-size: 0.8rem; padding: 5px 10px; }
    </style>
</head>
<body>

<header class="main-header text-center">
    <div class="container">
        <h1>COOPERATIVE DE TRANSPORT</h1>
        <p>ÉTAT DES PAIEMENTS PAR VOYAGEUR</p>
    </div>
</header>

<div class="container pb-5">
    <div class="card p-4 mb-4">
        <form method="get" class="row g-3 align-items-end justify-content-center">
            <div class="col-md-5">
                <label class="form-label fw-bold small text-uppercase">Filtrer par véhicule :</label>
                <select name="idvoit" class="form-select">
                    <option value="">Toutes les voitures</option>
                    <% while (rsVoitures.next()) { %>
                        <option value="<%= rsVoitures.getString("idvoit") %>" <%= (selectedId != null && selectedId.equals(rsVoitures.getString("idvoit"))) ? "selected" : "" %>>
                            <%= rsVoitures.getString("idvoit") %> - <%= rsVoitures.getString("Design") %>
                        </option>
                    <% } %>
                </select>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-filter px-4">AFFICHER</button>
            </div>
        </form>
    </div>

    <%
        String sql = "SELECT r.*, c.nom, c.numtel, v.frais, v.Design as voiture_design " +
                     "FROM RESERVER r " +
                     "JOIN CLIENT c ON r.idcli = c.idcli " +
                     "JOIN VOITURE v ON r.idvoit = v.idvoit " +
                     (selectedId != null && !selectedId.isEmpty() ? "WHERE r.idvoit = '" + selectedId + "' " : "") +
                     "ORDER BY r.payment ASC, c.nom ASC";
        
        Statement stmt2 = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ResultSet rsData = stmt2.executeQuery(sql);

        int countSans = 0, countAvec = 0, countTout = 0;
        long resteTotal = 0;
    %>

    <div class="section-title text-warning">● Voyageurs sans avance</div>
    <table class="table table-hover align-middle">
        <thead class="thead-dark">
            <tr>
                <th>Réf</th><th>Voyageur</th><th>Contact</th><th>Véhicule</th><th>Place</th><th>Frais</th><th>Reste</th>
            </tr>
        </thead>
        <tbody>
            <% 
                rsData.beforeFirst();
                while (rsData.next()) {
                    if ("sans avance".equals(rsData.getString("payment"))) {
                        countSans++;
                        resteTotal += rsData.getInt("frais");
            %>
            <tr>
                <td><%= rsData.getString("idreserv") %></td>
                <td class="fw-bold"><%= rsData.getString("nom") %></td>
                <td><%= rsData.getString("numtel") %></td>
                <td class="small"><%= rsData.getString("voiture_design") %></td>
                <td><span class="badge bg-light text-dark border"><%= rsData.getInt("place") %></span></td>
                <td><%= String.format("%,d", rsData.getInt("frais")) %></td>
                <td class="text-danger fw-bold"><%= String.format("%,d", rsData.getInt("frais")) %> Ar</td>
            </tr>
            <% } } %>
        </tbody>
    </table>

    <div class="section-title text-primary">● Voyageurs avec avance partielle</div>
    <table class="table table-hover align-middle">
        <thead class="thead-dark">
            <tr>
                <th>Réf</th><th>Voyageur</th><th>Véhicule</th><th>Place</th><th>Frais</th><th>Payé</th><th>Reste</th>
            </tr>
        </thead>
        <tbody>
            <% 
                rsData.beforeFirst();
                while (rsData.next()) {
                    if ("avec avance".equals(rsData.getString("payment"))) {
                        countAvec++;
                        int reste = rsData.getInt("frais") - rsData.getInt("montant_avance");
                        resteTotal += reste;
            %>
            <tr>
                <td><%= rsData.getString("idreserv") %></td>
                <td class="fw-bold"><%= rsData.getString("nom") %></td>
                <td class="small"><%= rsData.getString("voiture_design") %></td>
                <td><span class="badge bg-light text-dark border"><%= rsData.getInt("place") %></span></td>
                <td><%= String.format("%,d", rsData.getInt("frais")) %></td>
                <td class="text-success"><%= String.format("%,d", rsData.getInt("montant_avance")) %></td>
                <td class="text-danger fw-bold"><%= String.format("%,d", reste) %> Ar</td>
            </tr>
            <% } } %>
        </tbody>
    </table>

    <div class="section-title text-success">● Voyageurs en règle (Tout payé)</div>
    <table class="table table-hover align-middle">
        <thead class="thead-dark">
            <tr>
                <th>Réf</th><th>Voyageur</th><th>Véhicule</th><th>Place</th><th>Total payé</th><th>Statut</th>
            </tr>
        </thead>
        <tbody>
            <% 
                rsData.beforeFirst();
                while (rsData.next()) {
                    if ("tout payé".equals(rsData.getString("payment"))) {
                        countTout++;
            %>
            <tr>
                <td><%= rsData.getString("idreserv") %></td>
                <td class="fw-bold"><%= rsData.getString("nom") %></td>
                <td class="small"><%= rsData.getString("voiture_design") %></td>
                <td><span class="badge bg-light text-dark border"><%= rsData.getInt("place") %></span></td>
                <td class="fw-bold text-success"><%= String.format("%,d", rsData.getInt("frais")) %> Ar</td>
                <td><span class="badge bg-success badge-status">SOLDE OK</span></td>
            </tr>
            <% } } %>
        </tbody>
    </table>

    <div class="row mt-5">
        <div class="col-md-6">
            <div class="card-summary">
                <h5 class="fw-bold border-bottom pb-2 mb-3">SYNTHÈSE DU FLUX</h5>
                <div class="d-flex justify-content-between mb-2">
                    <span>Voyageurs non réglés :</span>
                    <span class="fw-bold"><%= countSans + countAvec %></span>
                </div>
                <div class="d-flex justify-content-between mb-2">
                    <span>Voyageurs en règle :</span>
                    <span class="fw-bold text-success"><%= countTout %></span>
                </div>
                <hr>
                <div class="d-flex justify-content-between">
                    <span class="h6 fw-bold">RESTE TOTAL À PERCEVOIR :</span>
                    <span class="h6 fw-bold text-danger"><%= String.format("%,d", resteTotal) %> Ar</span>
                </div>
            </div>
        </div>
    </div>

    <div class="text-center mt-5">
        <a href="../index.jsp" class="btn btn-outline-secondary px-4 fw-bold">RETOUR ACCUEIL</a>
    </div>
</div>

<% 
    rsData.close();
    stmt2.close();
    rsVoitures.close();
    stmt.close();
%>

<footer class="text-center py-4 text-secondary small border-top bg-white mt-auto">
    PROJET 5 - GESTION DE RESERVATION DES PLACES DE COOPERATIVE
</footer>

</body>
</html>