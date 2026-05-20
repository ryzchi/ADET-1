<?php

require_once 'config.php';

$result = $mysqli->query(
    'SELECT submissions.*, assignments.title AS assignment_title
     FROM submissions
     LEFT JOIN assignments
     ON submissions.assignment_id = assignments.id
     ORDER BY submitted_at DESC'
);

$submissions = [];

while ($row = $result->fetch_assoc()) {
    $submissions[] = $row;
}

jsonResponse([
    'success' => true,
    'submissions' => $submissions
]);