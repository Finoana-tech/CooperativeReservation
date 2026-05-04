package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Importations iText
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import dao.ReservationDAO;
import dao.ClientDAO;
import dao.VoitureDAO;
import model.Reservation;
import model.Client;
import model.Voiture;

@WebServlet("/BilletPdfServlet")
public class BilletPdfServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idreserv = request.getParameter("id");
        ReservationDAO resDAO = new ReservationDAO();
        Reservation res = resDAO.getById(idreserv);

        if (res != null) {
            ClientDAO clientDAO = new ClientDAO();
            VoitureDAO voitureDAO = new VoitureDAO();
            Client client = clientDAO.getById(res.getIdcli());
            Voiture voiture = voitureDAO.getById(res.getIdvoit());

            List<Reservation> toutesLesPlaces = resDAO.getPlacesByClientAndVoitureAndDate(
                    res.getIdcli(),
                    res.getIdvoit(),
                    res.getDateVoyage());

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "inline; filename=Recu_" + idreserv + ".pdf");

            Document document = new Document(PageSize.A6, 25, 25, 25, 25);

            try {
                PdfWriter.getInstance(document, response.getOutputStream());
                document.open();

                // Polices
                Font titleFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
                Font boldFont = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD);
                Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);
                Font smallFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL);
                Font footerFont = new Font(Font.FontFamily.HELVETICA, 8, Font.ITALIC);

                // EN-TÊTE
                Paragraph title = new Paragraph("COOPÉRATIVE DE TRANSPORT", titleFont);
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(title);

                Paragraph subtitle = new Paragraph("REÇU DE RÉSERVATION", boldFont);
                subtitle.setAlignment(Element.ALIGN_CENTER);
                document.add(subtitle);

                document.add(new Paragraph("───────────────────────────────", normalFont));

                document.add(new Paragraph("Reçu N° : " + res.getIdreserv(), boldFont));

                document.add(new Paragraph("Date de réservation : " + res.getDateReserv(), normalFont));
                document.add(new Paragraph("Date du voyage      : " + res.getDateVoyage(), normalFont));

                document.add(new Paragraph("───────────────────────────────", normalFont));

                // INFORMATIONS CLIENT
                if (client != null) {
                    document.add(new Paragraph("Nom du Client : " + client.getNom(), boldFont));
                    document.add(new Paragraph("Contact       : " + client.getNumtel(), normalFont));
                } else {
                    document.add(new Paragraph("Client ID : " + res.getIdcli(), normalFont));
                }

                document.add(new Paragraph("───────────────────────────────", normalFont));

                // INFORMATIONS VOITURE ET PLACES
                if (voiture != null) {
                    document.add(new Paragraph("Voiture N° : " + voiture.getIdvoit(), boldFont));
                    document.add(new Paragraph("Type       : " + voiture.getType(), normalFont));

                    // Affichage des places réservées
                    if (toutesLesPlaces != null && !toutesLesPlaces.isEmpty()) {
                        // Construction de la liste des numéros de places
                        StringBuilder placesStr = new StringBuilder();
                        for (int i = 0; i < toutesLesPlaces.size(); i++) {
                            if (i > 0)
                                placesStr.append(", ");
                            placesStr.append(toutesLesPlaces.get(i).getPlace());
                        }
                        document.add(new Paragraph("Place(s) N° : " + placesStr.toString(), normalFont));
                    } else {
                        document.add(new Paragraph("Place N° : " + res.getPlace(), normalFont));
                    }
                } else {
                    document.add(new Paragraph("Voiture ID : " + res.getIdvoit(), normalFont));
                    document.add(new Paragraph("Place N° : " + res.getPlace(), normalFont));
                }

                document.add(new Paragraph(" "));
                document.add(new Paragraph("───────────────────────────────", normalFont));

                if (voiture != null) {
                    document.add(new Paragraph("Frais : " + voiture.getFrais() + " Ar/place", boldFont));
                }

                String statutPaiement = res.getPayment();
                String statutAffichage = statutPaiement;
                if ("sans avance".equalsIgnoreCase(statutPaiement)) {
                    statutAffichage = "Sans Avance";
                } else if ("avec avance".equalsIgnoreCase(statutPaiement)) {
                    statutAffichage = "Avec Avance";
                } else if ("tout payé".equalsIgnoreCase(statutPaiement)) {
                    statutAffichage = "Tout Payé";
                }

                document.add(new Paragraph("Paiement : " + statutAffichage, normalFont));

                // Calcul et affichage du reste à payer
                if (voiture != null) {
                    int fraisTotal = voiture.getFrais() * (toutesLesPlaces != null ? toutesLesPlaces.size() : 1);
                    int montantAvance = res.getMontantAvance();
                    int resteAPayer = fraisTotal - montantAvance;

                    document.add(new Paragraph("Montant Avance : " + montantAvance + " Ar", normalFont));
                    if (resteAPayer > 0) {
                        document.add(new Paragraph("Reste à payer  : " + resteAPayer + " Ar", boldFont));
                    } else {
                        document.add(new Paragraph("Tout est payé !", boldFont));
                    }
                } else {
                    document.add(new Paragraph("Montant Avance : " + res.getMontantAvance() + " Ar", normalFont));
                }

                document.add(new Paragraph(" "));
                document.add(new Paragraph("───────────────────────────────", normalFont));

                Paragraph remerciement = new Paragraph("Merci de votre confiance !", normalFont);
                remerciement.setAlignment(Element.ALIGN_CENTER);
                document.add(remerciement);

                Paragraph bonVoyage = new Paragraph(" Bon voyage avec notre coopérative ! ", footerFont);
                bonVoyage.setAlignment(Element.ALIGN_CENTER);
                document.add(bonVoyage);

                document.close();

            } catch (DocumentException e) {
                throw new IOException("Erreur lors de la génération du PDF : " + e.getMessage());
            }
        } else {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<h3 style='color:red;'>Erreur : Réservation introuvable.</h3>");
            response.getWriter().println("<a href='javascript:history.back()'>← Retour</a>");
        }
    }
}