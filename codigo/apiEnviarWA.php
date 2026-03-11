<?php
require_once __DIR__ . '/api_guard.php';

//TOKEN QUE NOS DA FACEBOOK
$token = 'EAAPvKmMgHU8BOxJZCUgPqzNvFQ8SF53mybGZAAqovYxbympFSfuuT0kPn2PTa1kR1oVMbp3s68zZAUxxylwMqSXe2TgldN6isZAU8oWYQ7JMfineRoBGjeA2oO99yIkZAqTmRFpfsLH62GG4SW4nX1qQC3ZBhBBfvZARhn7miG30WvrjCuYZAhhYv1WbRgnlLGAMhDu7NYDxCcZBvMrJrCWguwOcZD';
//NUESTRO TELEFONO
$telefono = '573204409337';
//URL A DONDE SE MANDARA EL MENSAJE
$url = 'https://graph.facebook.com/v21.0/540197535839571/messages';

//CONFIGURACION DEL MENSAJE
$mensaje = ''
        . '{'
        . '"messaging_product": "whatsapp", '
        . '"to": "'.$telefono.'", '
        . '"type": "template", '
        . '"template": '
        . '{'
        . '     "name": "hello_world",'
        . '     "language":{ "code": "en_US" } '
        . '} '
        . '}';
//DECLARAMOS LAS CABECERAS
$header = array("Authorization: Bearer " . $token, "Content-Type: application/json",);
//INICIAMOS EL CURL
$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $url);
curl_setopt($curl, CURLOPT_POSTFIELDS, $mensaje);
curl_setopt($curl, CURLOPT_HTTPHEADER, $header);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
//OBTENEMOS LA RESPUESTA DEL ENVIO DE INFORMACION
$response = json_decode(curl_exec($curl), true);
//IMPRIMIMOS LA RESPUESTA 
print_r($response);
//OBTENEMOS EL CODIGO DE LA RESPUESTA
$status_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
//CERRAMOS EL CURL
curl_close($curl);
?>