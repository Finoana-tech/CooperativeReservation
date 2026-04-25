<%@ page isErrorPage="true" %>
<html>
<body style="background:white; padding:20px;">
<h2 style="color:red;">Erreur :</h2>
<p><%= exception.getMessage() %></p>
<pre>
<% exception.printStackTrace(new java.io.PrintWriter(out)); %>
</pre>
</body>
</html>