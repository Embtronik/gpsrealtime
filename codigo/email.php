<?php

// Usar las clases PHPMailer necesarias
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require '../vendor/autoload.php';

// Establecer la cabecera para JSON
header('Content-Type: application/json');

// Verifica que la solicitud sea POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // Obtener los datos enviados en el cuerpo de la solicitud
    $jsonData = file_get_contents('php://input');
    $data = json_decode($jsonData, true);

    // Recibe los datos del POST
    $emailUsuario = $data['emailUsuario'] ?? null;
    $nombreCliente = $data['nombreCliente'] ?? null;
    $codigo = $data['codigo'] ?? null;

    // Verifica que los datos necesarios no estén vacíos
    if (!empty($emailUsuario) && !empty($nombreCliente)) {
        
        // Validar el formato del email
        if (filter_var($emailUsuario, FILTER_VALIDATE_EMAIL)) {
            
            $mail = new PHPMailer(true);
            try {
                // Configuración del servidor SMTP
                $mail->SMTPDebug = SMTP::DEBUG_OFF;                      // Desactivar salida de debug en producción
                $mail->isSMTP();                                          // Usar SMTP
                $mail->Host       = getenv('SMTP_HOST')     ?: 'smtp.zoho.com';
                $mail->SMTPAuth   = true;
                $mail->Username   = getenv('SMTP_USER')     ?: 'comercial@gpsrealtime.com.co';
                $mail->Password   = getenv('SMTP_PASSWORD') ?: 'ai10rnYu@';
                $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
                $mail->Port       = (int)(getenv('SMTP_PORT') ?: 465);

                // Configuración del remitente y destinatario
                $mail->setFrom('comercial@gpsrealtime.com.co', 'GPS REAL TIME');
                $mail->addAddress($emailUsuario, $nombreCliente);         // Destinatario dinámico

                // Adjuntar el banner como un archivo embebido con el cid: "banner_cid"
                $mail->addEmbeddedImage('../img/banner.png', 'banner_cid');

                // Leer el archivo HTML y reemplazar los marcadores con los valores
                $htmlContent = file_get_contents('../html/plantilla_bienvenida.html');
                $htmlContent = str_replace('{nombreCliente}', $nombreCliente, $htmlContent);
                $htmlContent = str_replace('{codigo}', $codigo, $htmlContent);

                // Establecer el contenido del correo
                $mail->isHTML(true);
                $mail->CharSet = 'UTF-8';
                $mail->Subject = '¡Bienvenido a GPS REAL TIME!';
                $mail->Body    = $htmlContent;
                $mail->AltBody = 'Hola ' . $nombreCliente . ', La placa de tu vehículo es: ' . $codigo;

                // Enviar el correo
                $mail->send();
                echo json_encode(['status' => 'success', 'message' => 'Correo enviado correctamente']);
            } catch (Exception $e) {
                // Manejo de errores
                echo json_encode(['status' => 'error', 'message' => "El correo no pudo ser enviado. Error: {$mail->ErrorInfo}"]);
            }
        } else {
            // Email no válido
            echo json_encode(['status' => 'error', 'message' => 'El formato del correo electrónico es inválido']);
        }
        
    } else {
        // Si faltan datos
        echo json_encode(['status' => 'error', 'message' => 'Faltan datos requeridos']);
    }
} else {
    // Si no es una solicitud POST
    echo json_encode(['status' => 'error', 'message' => 'Método no permitido']);
}

?>
