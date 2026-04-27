<%@ page isErrorPage="true" language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Erreur - Gestion Cooperative</title>
    <style>
        body {
            background: white;
            padding: 20px;
            font-family: 'Segoe UI', Arial, sans-serif;
        }
        h2 {
            color: #dc3545;
        }
        .error-details {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            padding: 15px;
            border-radius: 4px;
            overflow-x: auto;
        }
        pre {
            margin: 0;
            font-size: 12px;
        }
    </style>
</head>
<body>

<h2>Erreur technique</h2>

<div class="error-details">
    <p><strong>Message :</strong> <%= exception.getMessage() %></p>
    <hr>
    <pre><% exception.printStackTrace(new java.io.PrintWriter(out)); %></pre>
</div>

<p style="margin-top: 20px;">
    <a href="${pageContext.request.contextPath}/index.jsp" style="color: #1a3a5f; text-decoration: none;">
        Retour à l'accueil
    </a>
</p>

</body>
</html>