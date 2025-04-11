import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:pub_app/models/asset.dart';
import 'package:pub_app/models/package.dart';
import 'package:pub_app/repository.dart';

class PackageAndVersion {
  PackageAndVersion(this.package, this.version);

  final String package;
  final String version;
}

Future<void> loadAssets(PackageAndVersion p) async {
  final isar = Isar.openSync(
    [PackageSchema, AssetSchema],
    inspector: false,
  );

  Asset? readme;
  Asset? changelog;

  final targz = await Repository(Dio()).downloadPackage(p.package, p.version);
  final tar = GZipDecoder().decodeBytes(targz);
  final archive = TarDecoder().decodeBytes(tar);

  for (final file in archive) {
    if (file.isFile) {
      final name = file.name.toLowerCase();
      if (readme == null && name == 'readme.md') {
        final content = utf8.decode(file.content as List<int>);
        readme = Asset(
          package: p.package,
          version: p.version,
          kind: AssetKind.readme,
          content: content,
        );
      } else if (changelog == null && name == 'changelog.md') {
        final content = utf8.decode(file.content as List<int>);
        changelog = Asset(
          package: p.package,
          version: p.version,
          kind: AssetKind.changelog,
          content: content,
        );
      }
    }

    if (readme != null && changelog != null) {
      break;
    }
  }

  if (readme != null || changelog != null) {
    isar.writeTxnSync(() {
      isar.assets.putAllSync([
        if (readme != null) readme,
        if (changelog != null) changelog,
      ]);
    });
  }
}
