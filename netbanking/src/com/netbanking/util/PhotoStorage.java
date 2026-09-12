package com.netbanking.util;

import javax.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;






public class PhotoStorage {

    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "webp");
    private static final long MAX_BYTES = 2L * 1024 * 1024;

    private PhotoStorage() {
    }








    public static String save(Part photoPart, String uploadsRealPath) throws IOException {
        if (photoPart == null || photoPart.getSize() <= 0) {
            return null;
        }
        if (photoPart.getSize() > MAX_BYTES) {
            throw new IllegalArgumentException("Photo must be 2MB or smaller");
        }

        String extension = extensionOf(photoPart.getSubmittedFileName());
        if (extension == null || !ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Photo must be a JPG, PNG, or WEBP image");
        }

        Path uploadsDir = Paths.get(uploadsRealPath);
        Files.createDirectories(uploadsDir);



        String filename = UUID.randomUUID() + "." + extension;
        try (InputStream in = photoPart.getInputStream()) {
            Files.copy(in, uploadsDir.resolve(filename), StandardCopyOption.REPLACE_EXISTING);
        }
        return filename;
    }

    private static String extensionOf(String submittedFileName) {
        if (submittedFileName == null) {
            return null;
        }
        int dot = submittedFileName.lastIndexOf('.');
        if (dot < 0 || dot == submittedFileName.length() - 1) {
            return null;
        }
        return submittedFileName.substring(dot + 1).toLowerCase();
    }
}
