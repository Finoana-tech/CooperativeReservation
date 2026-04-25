<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Reservation, model.Voiture" %>
<%
    // Récupération des données du Servlet
    Integer recetteTotale = (Integer) request.getAttribute("recetteTotale");
    List<Voiture> listeVoitures = (List<Voiture>) request.getAttribute("listeVoitures");
    String selectedVoit = (String) request.getAttribute("selectedVoit");
    Voiture voitDetails = (Voiture) request.getAttribute("voitureDetails");
    int fraisVoiture = (voitDetails != null) ? voitDetails.getFrais() : 0;
    
    List<Reservation> sansAvanceBrut = (List<Reservation>) request.getAttribute("sansAvance");
    List<Reservation> avecAvanceBrut = (List<Reservation>) request.getAttribute("avecAvance");
    List<Reservation> toutPayeBrut = (List<Reservation>) request.getAttribute("toutPaye");

    // --- FONCTION DE REGROUPEMENT POUR L'AFFICHAGE ---
    // Cette fonction permet de ne pas répéter le nom du client s'il a plusieurs places
    // tout en comptant le nombre réel de voyageurs (places).
%>
<%! 
    // Structure pour stocker les données groupées
    class GroupedRes {
        String nom;
        String tel;
        List<Integer> places = new ArrayList<>();
        int avanceTotale = 0;
    }

    Map<String, GroupedRes> regrouper(List<Reservation> liste) {
        Map<String, GroupedRes> map = new LinkedHashMap<>();
        if (liste != null) {
            for (Reservation r : liste) {
                String key = r.getNomClient() + r.getNumTelClient();
                if (!map.containsKey(key)) {
                    GroupedRes g = new GroupedRes();
                    g.nom = r.getNomClient();
                    g.tel = r.getNumTelClient();
                    map.put(key, g);
                }
                map.get(key).places.add(r.getPlace());
                map.get(key).avanceTotale += r.getMontantAvance();
            }
        }
        return map;
    }
%>
<%
    Map<String, GroupedRes> mapSansAvance = regrouper(sansAvanceBrut);
    Map<String, GroupedRes> mapAvecAvance = regrouper(avecAvanceBrut);
    Map<String, GroupedRes> mapToutPaye = regrouper(toutPayeBrut);
    
    int totalVoyageurs = (sansAvanceBrut != null ? sansAvanceBrut.size() : 0) + 
                         (avecAvanceBrut != null ? avecAvanceBrut.size() : 0) + 
                         (toutPayeBrut != null ? toutPayeBrut.size() : 0);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Statistiques - Gestion Cooperative</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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

        .stat-bar-container {
            background-color: #e9ecef;
            padding: 20px 0;
            border-bottom: 1px solid #dee2e6;
            margin-bottom: 30px;
        }

        .content-wrapper {
            flex: 1;
            margin-bottom: 40px;
        }

        .table-container {
            background-color: var(--white);
            border: 1px solid #dee2e6;
            padding: 25px;
            border-radius: 4px;
            margin-bottom: 30px;
        }

        .table thead {
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
            display: flex;
            justify-content: space-between;
        }

        .nav-actions {
            margin-bottom: 20px;
            display: flex;
            justify-content: flex-start;
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
            border: none;
        }
        .btn-main:hover { color: white; opacity: 0.9; }

        .recette-box {
            background-color: var(--white);
            border-left: 5px solid #198754;
            padding: 15px 25px;
            border-radius: 4px;
            display: inline-block;
        }

        footer {
            padding: 20px 0;
            border-top: 1px solid #dee2e6;
            font-size: 0.8rem;
            color: #6c757d;
            background-color: var(--white);
        }

        .badge-count {
            background-color: var(--primary-color);
            color: white;
            padding: 2px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        .badge-place {
            background-color: #f1f3f5;
            border: 1px solid #ccc;
            padding: 1px 5px;
            border-radius: 3px;
            font-size: 0.85rem;
            margin-right: 2px;
        }
    </style>
</head>
<body>

<header class="main-header text-center">
    <div class="container">
        <h1>COOPERATIVE DE TRANSPORT</h1>
        <p>STATISTIQUES ET ETATS DE PAIEMENT</p>
    </div>
</header>

<section class="stat-bar-container">
    <div class="container d-flex justify-content-between align-items-center">
        <div class="recette-box shadow-sm">
            <span class="text-muted small d-block">RECETTE TOTALE ACCUMULÉE</span>
            <strong class="fs-4" style="color: #198754;"><%= (recetteTotale != null) ? String.format("%,d", recetteTotale) : 0 %> Ar</strong>
        </div>
        
        <form action="<%= request.getContextPath() %>/StatistiqueServlet" method="get" class="d-flex gap-2">
            <select name="idvoit" class="form-select" style="min-width: 250px;" required>
                <option value="">-- Choisir une voiture --</option>
                <% if (listeVoitures != null) { 
                    for (Voiture v : listeVoitures) { 
                        String sel = (v.getIdvoit().equals(selectedVoit)) ? "selected" : "";
                %>
                    <option value="<%= v.getIdvoit() %>" <%= sel %>><%= v.getIdvoit() %> - <%= v.getDesign() %></option>
                <%  } 
                } %>
            </select>
            <button type="submit" class="btn-main">Filtrer</button>
        </form>
    </div>
</section>

<div class="container content-wrapper">
    <div class="nav-actions">
        <a href="<%= request.getContextPath() %>/index.jsp" class="btn-main">Retour Accueil</a>
    </div>

    <% if (selectedVoit != null) { %>
        
        <div class="table-container shadow-sm">
            <div class="table-title">
                <span>Voyageurs avec avance (Reste à payer)</span>
                <span class="badge-count"><%= (avecAvanceBrut != null) ? avecAvanceBrut.size() : 0 %> Voyageurs</span>
            </div>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>NOM DU CLIENT</th>
                        <th>PLACES</th>
                        <th class="text-center">NOMBRE</th>
                        <th>AVANCE PAYÉE</th>
                        <th>RESTE À PAYER</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (!mapAvecAvance.isEmpty()) {
                        for (GroupedRes g : mapAvecAvance.values()) { 
                            int montantDuTotal = fraisVoiture * g.places.size();
                            int reste = montantDuTotal - g.avanceTotale;
                    %>
                        <tr>
                            <td><strong><%= g.nom %></strong><br><small class="text-muted"><%= g.tel %></small></td>
                            <td>
                                <% for(Integer p : g.places) { %> <span class="badge-place">P<%= p %></span> <% } %>
                            </td>
                            <td class="text-center fw-bold"><%= g.places.size() %></td>
                            <td><%= String.format("%,d", g.avanceTotale) %> Ar</td>
                            <td class="text-danger fw-bold"><%= String.format("%,d", reste) %> Ar</td>
                        </tr>
                    <% } } else { %>
                        <tr><td colspan="5" class="text-center py-3 text-muted">Aucun voyageur trouvé</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="table-container shadow-sm">
            <div class="table-title">
                <span>Voyageurs ayant tout payé</span>
                <span class="badge-count"><%= (toutPayeBrut != null) ? toutPayeBrut.size() : 0 %> Voyageurs</span>
            </div>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>NOM DU CLIENT</th>
                        <th>PLACES</th>
                        <th class="text-center">NOMBRE</th>
                        <th>MONTANT TOTAL RÉGLÉ</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (!mapToutPaye.isEmpty()) {
                        for (GroupedRes g : mapToutPaye.values()) { %>
                        <tr>
                            <td><strong><%= g.nom %></strong><br><small class="text-muted"><%= g.tel %></small></td>
                            <td>
                                <% for(Integer p : g.places) { %> <span class="badge-place">P<%= p %></span> <% } %>
                            </td>
                            <td class="text-center fw-bold"><%= g.places.size() %></td>
                            <td><%= String.format("%,d", g.avanceTotale) %> Ar</td>
                        </tr>
                    <% } } else { %>
                        <tr><td colspan="4" class="text-center py-3 text-muted">Aucun voyageur trouvé</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="table-container shadow-sm">
            <div class="table-title">
                <span>Voyageurs sans avance (Montant dû)</span>
                <span class="badge-count"><%= (sansAvanceBrut != null) ? sansAvanceBrut.size() : 0 %> Voyageurs</span>
            </div>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>NOM DU CLIENT</th>
                        <th>PLACES</th>
                        <th class="text-center">NOMBRE</th>
                        <th>TOTAL À RÉGLER</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (!mapSansAvance.isEmpty()) {
                        for (GroupedRes g : mapSansAvance.values()) { 
                            int totalDu = fraisVoiture * g.places.size();
                    %>
                        <tr>
                            <td><strong><%= g.nom %></strong><br><small class="text-muted"><%= g.tel %></small></td>
                            <td>
                                <% for(Integer p : g.places) { %> <span class="badge-place">P<%= p %></span> <% } %>
                            </td>
                            <td class="text-center fw-bold"><%= g.places.size() %></td>
                            <td class="fw-bold"><%= String.format("%,d", totalDu) %> Ar</td>
                        </tr>
                    <% } } else { %>
                        <tr><td colspan="4" class="text-center py-3 text-muted">Aucun voyageur trouvé</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>

    <% } else { %>
        <div class="text-center mt-5">
            <p class="text-muted">Veuillez sélectionner un véhicule pour afficher le détail des voyageurs.</p>
        </div>
    <% } %>
</div>

<footer class="text-center">
    <div class="container">
        GESTION DE RESERVATION DES PLACES DE COOPERATIVE - MODULE STATISTIQUES
    </div>
</footer>

</body>
</html>