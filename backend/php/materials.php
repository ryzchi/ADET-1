<?php
require_once 'config.php';

header('Content-Type: application/json; charset=utf-8');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $mysqli->prepare("SELECT id, title, subject, type, file_url, created_at FROM materials ORDER BY created_at DESC");
    $stmt->execute();
    $result = $stmt->get_result();
    $materials = [];
    while ($row = $result->fetch_assoc()) {
        $materials[] = $row;
    }
    $stmt->close();
    jsonResponse(['success' => true, 'materials' => $materials]);
}

elseif ($method === 'POST') {
    $input = requestBody();
    $action = $input['action'] ?? 'create';
    
    if ($action === 'create') {
        $title = trim($input['title'] ?? '');
        $subject = trim($input['subject'] ?? '');
        $type = trim($input['type'] ?? '');
        $fileUrl = trim($input['file_url'] ?? '');
        $uploadedBy = intval($input['uploaded_by'] ?? 0);
        
        if (empty($title) || empty($subject)) {
            jsonResponse(['success' => false, 'message' => 'Title and subject are required']);
        }
        
        // Check if uploaded_by column exists (optional)
        $checkColumn = $mysqli->query("SHOW COLUMNS FROM materials LIKE 'uploaded_by'");
        $hasUploadedBy = $checkColumn && $checkColumn->num_rows > 0;
        
        if ($hasUploadedBy) {
            $stmt = $mysqli->prepare("INSERT INTO materials (title, subject, type, file_url, uploaded_by) VALUES (?, ?, ?, ?, ?)");
            $stmt->bind_param('ssssi', $title, $subject, $type, $fileUrl, $uploadedBy);
        } else {
            $stmt = $mysqli->prepare("INSERT INTO materials (title, subject, type, file_url) VALUES (?, ?, ?, ?)");
            $stmt->bind_param('ssss', $title, $subject, $type, $fileUrl);
        }
        
        $saved = $stmt->execute();
        $stmt->close();
        
        if ($saved) {
            jsonResponse(['success' => true, 'message' => 'Material created']);
        } else {
            jsonResponse(['success' => false, 'message' => 'Database insert failed: ' . $mysqli->error]);
        }
    }
    elseif ($action === 'delete') {
        $id = intval($input['id'] ?? 0);
        if ($id <= 0) {
            jsonResponse(['success' => false, 'message' => 'Invalid ID']);
        }
        $stmt = $mysqli->prepare("DELETE FROM materials WHERE id = ?");
        $stmt->bind_param('i', $id);
        $deleted = $stmt->execute();
        $stmt->close();
        jsonResponse(['success' => $deleted, 'message' => $deleted ? 'Deleted' : 'Delete failed']);
    }
    else {
        jsonResponse(['success' => false, 'message' => 'Unsupported action: ' . $action]);
    }
}
else {
    jsonResponse(['success' => false, 'message' => 'Unsupported method: ' . $method]);
}
?>