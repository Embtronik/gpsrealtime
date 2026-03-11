<?php
/*
 * VERIFICACION DEL WEBHOOK
*/
//TOQUEN QUE QUERRAMOS PONER 
$token = 'gpsrealtime';
//RETO QUE RECIBIREMOS DE FACEBOOKCursos de marketing para influencers
$palabraReto = $_GET['hub_challenge'];
//TOQUEN DE VERIFICACION QUE RECIBIREMOS DE FACEBOOKCursos de marketing para influencers
$tokenVerificacion = $_GET['hub_verify_token'];
//SI EL TOKEN QUE GENERAMOS ES EL MISMO QUE NOS ENVIA FACEBOOK RETORNAMOS EL RETO PARA VALIDAR QUE SOMOS NOSOTROS
if ($token === $tokenVerificacion) {
    echo $palabraReto;
    exit;
}
/*
 * RECEPCION DE MENSAJES
 */
//LEEMOS LOS DATOS ENVIADOS POR WHATSAPP
$respuesta = file_get_contents("php://input");
//CONVERTIMOS EL JSON EN ARRAY DE PHP
$respuesta = json_decode($respuesta, true);
//EXTRAEMOS EL TELEFONO DEL ARRAY
$mensaje="Telefono:".$respuesta['entry'][0]['changes'][0]['value']['messages'][0]['from']."</br>";
//EXTRAEMOS EL MENSAJE DEL ARRAY
$mensaje.="Mensaje:".$respuesta['entry'][0]['changes'][0]['value']['messages'][0]['text']['body'];
//GUARDAMOS EL MENSAJE Y LA RESPUESTA EN EL ARCHIVO text.txt
file_put_contents("text.txt", $mensaje);

?>