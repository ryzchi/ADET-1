<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $result = $mysqli->query('SELECT id, title, description, deadline, created_at FROM assignments ORDER BY created_at DESC');
    $assignments = [];
    while ($row = $result->fetch_assoc()) {
        $assignments[] = $row;
    }
    jsonResponse(['success' => true, 'assignments' => $assignments]);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = requestBody();
    $action = sanitize($input['action'] ?? 'create');

    if ($action === 'create') {
        $title = sanitize($input['title'] ?? '');
        $description = sanitize($input['description'] ?? '');
        $deadline = sanitize($input['deadline'] ?? '');

        if (empty($title) || empty($deadline)) {
            jsonResponse(['success' => false, 'message' => 'Title and deadline are required']);
        }

        $stmt = $mysqli->prepare('INSERT INTO assignments (title, description, deadline) VALUES (?, ?, ?)');
        $stmt->bind_param('sss', $title, $description, $deadline);
        $saved = $stmt->execute();
        $stmt->close();

        if (!$saved) {
            jsonResponse(['success' => false, 'message' => 'Failed to create assignment']);
        }

        jsonResponse(['success' => true, 'message' => 'Assignment created']);
    }

    if ($action === 'edit') {
        $id = intval($input['id'] ?? 0);
        $title = sanitize($input['title'] ?? '');
        $description = sanitize($input['description'] ?? '');
        $deadline = sanitize($input['deadline'] ?? '');

        if ($id <= 0 || empty($title) || empty($deadline)) {
            jsonResponse(['success' => false, 'message' => 'Assignment id, title and deadline are required']);
        }

        $stmt = $mysqli->prepare('UPDATE assignments SET title = ?, description = ?, deadline = ? WHERE id = ?');
        $stmt->bind_param('sssi', $title, $description, $deadline, $id);
        $updated = $stmt->execute();
        $stmt->close();

        if (!$updated) {
            jsonResponse(['success' => false, 'message' => 'Failed to update assignment']);
        }

        jsonResponse(['success' => true, 'message' => 'Assignment updated']);
    }

    if ($action === 'delete') {
        $id = intval($input['id'] ?? 0);
        if ($id <= 0) {
            jsonResponse(['success' => false, 'message' => 'Assignment id is required']);
        }

        $stmt = $mysqli->prepare('DELETE FROM assignments WHERE id = ?');
        $stmt->bind_param('i', $id);
        $deleted = $stmt->execute();
        $stmt->close();

        if (!$deleted) {
            jsonResponse(['success' => false, 'message' => 'Failed to delete assignment']);
        }

        jsonResponse(['success' => true, 'message' => 'Assignment deleted']);
    }
}

jsonResponse(['success' => false, 'message' => 'Unsupported method']);
