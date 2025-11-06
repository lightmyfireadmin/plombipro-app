import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "PlombiPro - Logiciel de facturation pour plombiers | Devis & Factures",
  description: "Le seul logiciel de facturation qui scanne vos factures fournisseurs et intègre les catalogues Point P et Cedeo. Créez devis et factures en quelques clics. Essai gratuit.",
  keywords: "logiciel facturation plombier, devis plomberie, facture plombier, gestion chantiers, Point P, Cedeo, OCR facture",
  authors: [{ name: "PlombiPro" }],
  creator: "PlombiPro",
  publisher: "PlombiPro",
  metadataBase: new URL('https://plombipro.fr'),
  openGraph: {
    type: "website",
    locale: "fr_FR",
    url: "https://plombipro.fr",
    title: "PlombiPro - Logiciel de facturation pour plombiers",
    description: "Le seul logiciel de facturation qui scanne vos factures fournisseurs et intègre les catalogues Point P et Cedeo.",
    siteName: "PlombiPro",
  },
  twitter: {
    card: "summary_large_image",
    title: "PlombiPro - Logiciel de facturation pour plombiers",
    description: "Le seul logiciel de facturation qui scanne vos factures fournisseurs et intègre les catalogues Point P et Cedeo.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr">
      <body className={`${inter.variable} antialiased`}>
        {children}
      </body>
    </html>
  );
}
