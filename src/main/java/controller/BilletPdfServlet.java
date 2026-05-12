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
import com.itextpdf.text.pdf.PdfWriter;

import dao.ReservationDAO;
import dao.ClientDAO;
import dao.VoitureDAO;
import model.Reservation;
import model.Client;
import model.Voiture;

import java.sql.Timestamp;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@WebServlet("/BilletPdfServlet")
public class BilletPdfServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String formatDateFR(Object dateObj) {
        if (dateObj == null)
            return "";
        try {
            LocalDate date = null;
            if (dateObj instanceof String) {
                String dateStr = ((String) dateObj).trim();
                if (dateStr.isEmpty())
                    return "";
                String dateOnly = dateStr.substring(0, 10);
                date = LocalDate.parse(dateOnly);
            } else if (dateObj instanceof Timestamp) {
                date = ((Timestamp) dateObj).toLocalDateTime().toLocalDate();
            } else if (dateObj instanceof Date) {
                date = ((Date) dateObj).toLocalDate();
            } else {
                return dateObj.toString();
            }
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMMM yyyy", Locale.FRENCH);
            return date.format(formatter);
        } catch (Exception e) {
            return dateObj.toString();
        }
    }

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

            // Récupération de toutes les places liées à cette réservation groupée
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

                Font titleFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
                Font boldFont = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD);
                Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);
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
                document.add(new Paragraph("Date de réservation : " + formatDateFR(res.getDateReserv()), normalFont));
                document.add(new Paragraph("Date du voyage     : " + formatDateFR(res.getDateVoyage()), normalFont));
                document.add(new Paragraph("───────────────────────────────", normalFont));

                if (client != null) {
                    document.add(new Paragraph("Nom du Client : " + client.getNom(), boldFont));
                    document.add(new Paragraph("Contact       : " + client.getNumtel(), normalFont));
                }

                document.add(new Paragraph("───────────────────────────────", normalFont));

                if (voiture != null) {
                    document.add(new Paragraph("Voiture N° : " + voiture.getIdvoit(), boldFont));
                    document.add(new Paragraph("Type       : " + voiture.getType(), normalFont));

                    // Gestion de l'affichage des places
                    if (toutesLesPlaces != null && !toutesLesPlaces.isEmpty()) {
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
                }

                document.add(new Paragraph(" "));
                document.add(new Paragraph("───────────────────────────────", normalFont));

                // LOGIQUE DE CALCUL
                if (voiture != null) {
                    int prixParPlace = voiture.getFrais();
                    int nombrePlaces = (toutesLesPlaces != null) ? toutesLesPlaces.size() : 1;
                    int fraisTotalGroupe = prixParPlace * nombrePlaces;

                    // On additionne les avances de TOUTES les lignes du groupe
                    int sommeAvances = 0;
                    if (toutesLesPlaces != null) {
                        for (Reservation rGroup : toutesLesPlaces) {
                            sommeAvances += rGroup.getMontantAvance();
                        }
                    } else {
                        sommeAvances = res.getMontantAvance();
                    }

                    int resteAPayer = fraisTotalGroupe - sommeAvances;

                    document.add(new Paragraph(
                            "Frais total (" + nombrePlaces + " places) : " + fraisTotalGroupe + " Ar", boldFont));
                    document.add(new Paragraph("Total Avances versées : " + sommeAvances + " Ar", normalFont));

                    if (resteAPayer > 0) {
                        document.add(new Paragraph("Reste à payer total : " + resteAPayer + " Ar", boldFont));
                    } else {
                        document.add(new Paragraph("Statut : TOUT EST PAYÉ !", boldFont));
                    }
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