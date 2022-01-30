#!/usr/bin/php -q
<?php

$im = imagecreatefrompng("../unifieddyes/textures/unifieddyes_palette_extended.png");
if(!imageistruecolor($im)) imagepalettetotruecolor($im);
$width = imagesx($im);
$height = imagesy($im);
$i = 0;
echo "colored_eggs.colors = {\n";
for ($y = 0; $y < $height; $y++){
	for ($x = 0; $x < $width; $x++){
		$c = imagecolorat($im, $x, $y);
//		$a = ($c & 0x7F000000) >> 24;
		$r = ($c & 0xFF0000) >> 16;
		$g = ($c & 0x00FF00) >> 8;
		$b = ($c & 0x0000FF);

		printf("\t\"%02X%02X%02X\",\n", $r, $g, $b);
		$i++;
		if($i > 255) break;
	}
}
imagedestroy($im);
echo "}\n";

?>
