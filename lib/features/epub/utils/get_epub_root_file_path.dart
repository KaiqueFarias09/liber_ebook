import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:liber_epub/features/epub/constants/epub_constants.dart'
    as epub_constants;
import 'package:xml/xml.dart';

Future<String?> getEpubRootFilePath(final Archive epubArchive) async {
  final containerFileEntry = _getContainerFileEntry(epubArchive);
  final containerDocument = XmlDocument.parse(convert.utf8.decode(
    containerFileEntry.content as List<int>,
  ));

  final package = _getPackageElement(containerDocument);
  return _getRootFilePath(package);
}

ArchiveFile _getContainerFileEntry(final Archive epubArchive) {
  return epubArchive.files.firstWhere(
    (final file) => file.name == epub_constants.containerFilepath,
    orElse: () => throw Exception(
      'EPUB parsing error: ${epub_constants.containerFilepath} '
      'file not found in archive.',
    ),
  );
}

XmlElement _getPackageElement(final XmlDocument containerDocument) {
  final package = containerDocument
      .findElements(
        'container',
        namespace: epub_constants.containerNamespace,
      )
      .firstOrNull;

  if (package == null) {
    throw Exception('EPUB parsing error: Invalid epub container');
  }

  return package;
}

String? _getRootFilePath(final XmlElement package) {
  final rootFileElement = package.descendants.firstWhere(
    (final element) =>
        element is XmlElement && 'rootfile' == element.name.local,
    orElse: () => throw Exception(
      'EPUB parsing error: rootfile element not found in container file',
    ),
  );
  return rootFileElement.getAttribute('full-path');
}