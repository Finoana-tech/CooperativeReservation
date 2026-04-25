package controller;

import dao.ClientDAO;
import model.Client;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ClientServlet")
public class ClientServlet extends HttpServlet {
    private ClientDAO cliDAO = new ClientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String search = request.getParameter("search");

        // 1. Logique de Suppression
        if ("delete".equals(action)) {
            String idStr = request.getParameter("id"); // Corrigé ici : on attend 'id'
            if (idStr != null) {
                int id = Integer.parseInt(idStr);
                cliDAO.supprimer(id);
                // Redirection avec message de succès pour le script JS
                response.sendRedirect("ClientServlet?msg=Client supprime avec succes");
                return;
            }
        }

        // 2. Logique d'affichage et de recherche
        List<Client> liste;
        if (search != null && !search.trim().isEmpty()) {
            liste = cliDAO.rechercher(search);
        } else {
            liste = cliDAO.getAll();
        }

        request.setAttribute("clients", liste);
        request.getRequestDispatcher("client/clientList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String idStr = request.getParameter("idcli");
        String nom = request.getParameter("nom");
        String tel = request.getParameter("numtel");

        String message = "";
        try {
            if ("update".equals(action) && idStr != null) {
                int id = Integer.parseInt(idStr);
                Client c = new Client(id, nom, tel);
                cliDAO.modifier(c);
                message = "Modification enregistree";
            } else {
                Client c = new Client(nom, tel);
                cliDAO.ajouter(c);
                message = "Client ajoute avec succes";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Erreur lors de l'operation";
        }

        // Redirection vers le doGet pour rafraîchir la liste avec le message
        response.sendRedirect("ClientServlet?msg=" + message);
    }
}