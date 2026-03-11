<?php
require_once __DIR__ . '/api_guard.php';

// Configuración de la API
$access_token = "66edef5b42d30";
$instance_id = "609ACF283XXXX";
$number = "573204409337"; // Número de WhatsApp destino (código de país + número)
$message = "Hola! Este es un mensaje de prueba desde PHP.";

// URL de la API
$url = "https://app.whatspro.co/api/send?number=$number&type=text&message=" . urlencode($message) . "&instance_id=$instance_id&access_token=$access_token";

// Inicializar cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);

// Ejecutar petición
$response = curl_exec($ch);

// Manejar errores
if (curl_errno($ch)) {
    echo "Error en la solicitud: " . curl_error($ch);
} else {
    echo "Respuesta de la API: " . $response;
}

// Cerrar conexión
curl_close($ch);
?>
