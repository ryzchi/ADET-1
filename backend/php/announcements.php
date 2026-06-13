<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $mysqli->prepare("SELECT id, title, content, created_at FROM announcements ORDER BY created_at DESC");
    $stmt->execute();
    $result = $stmt->get_result();
    $announcements = [];
    while ($row = $result->fetch_assoc()) {
        $announcements[] = $row;
    }
    $stmt->close();
    jsonResponse(['success' => true, 'announcements' => $announcements]);
}

if ($method === 'POST') {
    $input = requestBody();
    $action = $input['action'] ?? 'create';
    if ($action === 'create') {
        $title = sanitize($input['title'] ?? '');
        $content = sanitize($input['content'] ?? '');
        $authorId = intval($input['author_id'] ?? 0);
        if (empty($title) || empty($content)) {
            jsonResponse(['success' => false, 'message' => 'Title and content required']);
        }
        $stmt = $mysqli->prepare("INSERT INTO announcements (title, content, author_id) VALUES (?, ?, ?)");
        $stmt->bind_param('ssi', $title, $content, $authorId);
        $saved = $stmt->execute();
        $stmt->close();
        if ($saved) {
            jsonResponse(['success' => true, 'message' => 'Announcement created']);
        } else {
            jsonResponse(['success' => false, 'message' => 'Failed to create announcement']);
        }
    } elseif ($action === 'delete') {
        $id = intval($input['id'] ?? 0);
        if ($id <= 0) {
            jsonResponse(['success' => false, 'message' => 'Invalid ID']);
        }
        $stmt = $mysqli->prepare("DELETE FROM announcements WHERE id = ?");
        $stmt->bind_param('i', $id);
        $deleted = $stmt->execute();
        $stmt->close();
        jsonResponse(['success' => $deleted, 'message' => $deleted ? 'Deleted' : 'Delete failed']);
    }
}

jsonResponse(['success' => false, 'message' => 'Unsupported method']);