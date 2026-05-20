<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $query = sanitize($_GET['q'] ?? '');
    $subjectFilter = sanitize($_GET['subject'] ?? '');
    $typeFilter = sanitize($_GET['type'] ?? '');

    $sql = 'SELECT id, title, subject, file_url, type, created_at FROM materials';
    $conditions = [];

    if ($query !== '') {
        $escapedQuery = $mysqli->real_escape_string('%' . $query . '%');
        $conditions[] = "(title LIKE '$escapedQuery' OR subject LIKE '$escapedQuery')";
    }
    if ($subjectFilter !== '') {
        $escapedSubject = $mysqli->real_escape_string($subjectFilter);
        $conditions[] = "subject = '$escapedSubject'";
    }
    if ($typeFilter !== '') {
        $escapedType = $mysqli->real_escape_string($typeFilter);
        $conditions[] = "type = '$escapedType'";
    }

    if (!empty($conditions)) {
        $sql .= ' WHERE ' . implode(' AND ', $conditions);
    }
    $sql .= ' ORDER BY created_at DESC';

    $result = $mysqli->query($sql);
    $materials = [];
    while ($row = $result->fetch_assoc()) {
        $materials[] = $row;
    }
    jsonResponse(['success' => true, 'materials' => $materials]);
}

jsonResponse(['success' => false, 'message' => 'Unsupported method']);
