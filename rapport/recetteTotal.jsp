<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DatabaseConnection" %>
<%
    Connection conn = DatabaseConnection.getConnection();
    
    // 1. Recette totale théorique (Somme des frais de toutes les voitures réservées)
    String sqlTotal = "SELECT SUM(v.frais) as total FROM RESERVER r JOIN VOITURE v ON r.idvoit = v.idvoit";
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery(sqlTotal);
    double totalGeneral = 0;
    if (rs.next()) {
        totalGeneral = rs.getDouble("total");
    }
    
    // 2. Détail par type de paiement
    String sqlDetails = "SELECT payment, COUNT(*) as nb, SUM(v.frais) as total " +
                        "FROM RESERVER r JOIN VOITURE v ON r.idvoit = v.idvoit " +
                        "GROUP BY payment";
    ResultSet rs2 = stmt.executeQuery(sqlDetails);
    
    double totalSansAvance = 0, totalAvecAvance = 0, totalToutPaye = 0;
    int nbSansAvance = 0, nbAvecAvance = 0, nbToutPaye = 0;
    
    while (rs2.next()) {
        String payment = rs2.getString("payment");
        int nb = rs2.getInt("nb");
        double total = rs2.getDouble("total");
        
        if ("sans avance".equals(payment)) {
            totalSansAvance = total; nbSansAvance = nb;
        } else if ("avec avance".equals(payment)) {
            totalAvecAvance = total; nbAvecAvance = nb;
        } else if ("tout payé".equals(payment)) {
            totalToutPaye = total; nbToutPaye = nb;
        }
    }
    rs.close();
    rs2.close();
    stmt.close();
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recette Totale - Cooperative</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root { --primary-color: #1a3a5f; --bg-color: #f8f9fa; }
        body { background-color: var(--bg-color); font-family: 'Segoe UI', sans-serif; min-height: 100vh; display: flex; flex-direction: column; }
        
        .main-header { background-color: var(--primary-color); color: white; padding: 30px 0; margin-bottom: 40px; }
        
        .stats-card {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }

        .total-amount {
            font-size: 3.5rem;
            font-weight: 800;
            color: var(--primary-color);
            margin: 20px 0;
            border-bottom: 2px solid var(--primary-color);
            display: inline-block;
            padding-bottom: 10px;
        }

        .detail-box {
            background-color: #f1f3f5;
            border-radius: 4px;
            padding: 25px;
            margin-top: 30px;
            text-align: left;
        }

        .table-summary { margin-bottom: 0; }
        .table-summary td { padding: 12px 8px; border-bottom: 1px solid #dee2e6; }
        .table-summary tr:last-child td { border-bottom: none; }
        
        .label-payment { font-weight: bold; text-transform: uppercase; font-size: 0.85rem; color: #555; }
        .btn-back { border: 2px solid var(--primary-color); color: var(--primary-color); font-weight: bold; text-transform: uppercase; text-decoration: none; padding: 10px 25px; transition: all 0.3s; }
        .btn-back:hover { background: var(--primary-color); color: white; }
        
        footer { padding: 20px 0; border-top: 1px solid #dee2e6; font-size: 0.8rem; color: #6c757d; background: white; margin-top: auto; }
    </style>
</head>
<body>

<header class="main-header text-center">
    <div class="container">
        <h1>COOPERATIVE DE TRANSPORT</h1>
        <p>ANALYSE FINANCIÈRE DES RÉSERVATIONS</p>
    </div>
</header>

<div class="container mb-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="stats-card">
                <h2 class="h5 fw-bold text-uppercase text-secondary">Chiffre d'Affaires Global</h2>
                <div class="total-amount"><%= String.format("%,.0f", totalGeneral) %> Ar</div>
                <p class="text-muted">Somme totale des frais de transport pour l'ensemble des réservations enregistrées.</p>

                <div class="detail-box">
                    <h3 class="h6 fw-bold mb-4 text-uppercase"><i class="bi bi-list-check"></i> Répartition par type de règlement</h3>
                    <table class="table table-summary">
                        <tr>
                            <td class="label-payment text-warning">Sans avance</td>
                            <td class="text-end fw-bold"><%= String.format("%,.0f", totalSansAvance) %> Ar</td>
                            <td class="text-end text-muted small">(<%= nbSansAvance %> réserv.)</td>
                        </tr>
                        <tr>
                            <td class="label-payment text-primary">Avec avance</td>
                            <td class="text-end fw-bold"><%= String.format("%,.0f", totalAvecAvance) %> Ar</td>
                            <td class="text-end text-muted small">(<%= nbAvecAvance %> réserv.)</td>
                        </tr>
                        <tr>
                            <td class="label-payment text-success">Tout payé</td>
                            <td class="text-end fw-bold"><%= String.format("%,.0f", totalToutPaye) %> Ar</td>
                            <td class="text-end text-muted small">(<%= nbToutPaye %> réserv.)</td>
                        </tr>
                        <tr class="table-light">
                            <td class="label-payment fw-bolder">Total Général</td>
                            <td class="text-end fw-bolder" style="color: var(--primary-color)"><%= String.format("%,.0f", totalGeneral) %> Ar</td>
                            <td class="text-end fw-bold"><%= (nbSansAvance + nbAvecAvance + nbToutPaye) %> Total</td>
                        </tr>
                    </table>
                </div>

                <div class="mt-5 d-flex justify-content-center gap-3">
                    <a href="paiements.jsp" class="btn-back">Suivi Paiements</a>
                    <a href="../index.jsp" class="btn-back">Accueil</a>
                </div>
            </div>
        </div>
    </div>
</div>

<footer class="text-center">
    <div class="container">PROJET 5 - GESTION DE RESERVATION DES PLACES DE COOPERATIVE</div>
</footer>

</body>
</html>