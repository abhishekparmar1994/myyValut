<?php

function fetchHtmlWithCurl($url)
{
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_MAXREDIRS, 5);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_ENCODING, '');
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return ($httpCode === 200) ? $response : false;
}

$url = 'https://laraveldaily.com/course/laravel-from-scratch';
echo "Testing URL: $url\n";
$html = fetchHtmlWithCurl($url);

if ($html) {
    echo "Successfully fetched " . strlen($html) . " bytes\n";
    
    libxml_use_internal_errors(true);
    $doc = new \DOMDocument();
    @$doc->loadHTML(mb_convert_encoding($html, 'HTML-ENTITIES', 'UTF-8'));
    libxml_clear_errors();
    $xpath = new \DOMXPath($doc);
    
    $queries = [
        'Title' => 'string(//meta[@property="og:title"]/@content | //meta[@name="twitter:title"]/@content | //title)',
        'Desc' => 'string(//meta[@property="og:description"]/@content | //meta[@name="description"]/@content)',
        'Image' => 'string(//meta[@property="og:image"]/@content | //meta[@name="twitter:image"]/@content | //img[1]/@src)',
    ];
    
    foreach ($queries as $label => $query) {
        $val = trim($xpath->evaluate($query));
        echo "$label: [$val]\n";
    }
} else {
    echo "Failed to fetch $url\n";
}
