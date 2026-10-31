class PhotoCreator {
  final String idUser;
  final String username;
  final String? avatarUrl;

  const PhotoCreator({
    required this.idUser,
    required this.username,
    this.avatarUrl,
  });

  factory PhotoCreator.fromJson(Map<String, dynamic> json) {
    return PhotoCreator(
      idUser: (json['id_user'] ?? json['id'] ?? '').toString(),
      username: (json['username'] ?? 'Creator').toString(),
      avatarUrl: (json['avatar_url'] ?? json['profile_picture_url']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_user': idUser, 'username': username, 'avatar_url': avatarUrl};
  }
}

class PhotoModel {
  final int idPhoto;
  final String idUser;
  final int? idCategory;
  final String? categoryName;
  final String title;
  final String? description;
  final String imageUrl;
  final String thumbnailUrl;
  final String mediumUrl;
  final String highResUrl;
  final String? cloudinaryPublicId;
  final int? width;
  final int? height;
  final String? cameraMake;
  final String? cameraModel;
  final String? lens;
  final String? focalLength;
  final String? aperture;
  final String? shutterSpeed;
  final String? iso;
  final String? takenAt;
  final String? createdAt;
  final String? updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final PhotoCreator? creator;

  const PhotoModel({
    required this.idPhoto,
    required this.idUser,
    this.idCategory,
    this.categoryName,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.mediumUrl,
    required this.highResUrl,
    this.cloudinaryPublicId,
    this.width,
    this.height,
    this.cameraMake,
    this.cameraModel,
    this.lens,
    this.focalLength,
    this.aperture,
    this.shutterSpeed,
    this.iso,
    this.takenAt,
    this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.creator,
  });

  /// Short camera and exposure summary badge string (e.g. "SONY A7M4 • f/2.8 • 1/500s").
  String get cameraBadgeText {
    final parts = <String>[];
    if (cameraModel != null && cameraModel!.isNotEmpty) {
      parts.add(cameraModel!);
    } else if (cameraMake != null && cameraMake!.isNotEmpty) {
      parts.add(cameraMake!);
    }
    if (aperture != null && aperture!.isNotEmpty) {
      parts.add(aperture!);
    }
    if (shutterSpeed != null && shutterSpeed!.isNotEmpty) {
      parts.add(shutterSpeed!);
    }
    return parts.isEmpty ? 'sRGB Capture' : parts.join(' • ');
  }

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    final id = json['id_photo'] is int
        ? json['id_photo'] as int
        : int.tryParse(
                json['id_photo']?.toString() ?? json['id']?.toString() ?? '0',
              ) ??
              0;

    final imgUrl = (json['image_url'] ?? '').toString();
    final thumbUrl = (json['thumbnail_url'] ?? imgUrl).toString();
    final medUrl = (json['medium_url'] ?? imgUrl).toString();
    final hiResUrl = (json['high_res_url'] ?? imgUrl).toString();

    PhotoCreator? creatorObj;
    if (json['creator'] is Map<String, dynamic>) {
      creatorObj = PhotoCreator.fromJson(
        json['creator'] as Map<String, dynamic>,
      );
    } else if (json['profiles'] is Map<String, dynamic>) {
      creatorObj = PhotoCreator.fromJson(
        json['profiles'] as Map<String, dynamic>,
      );
    }

    return PhotoModel(
      idPhoto: id,
      idUser: (json['id_user'] ?? json['user_id'] ?? '').toString(),
      idCategory: json['id_category'] is int
          ? json['id_category'] as int
          : int.tryParse(
              json['id_category']?.toString() ??
                  json['category_id']?.toString() ??
                  '',
            ),
      categoryName: json['category_name'] as String?,
      title: (json['title'] ?? 'Untitled').toString(),
      description: json['description'] as String?,
      imageUrl: imgUrl,
      thumbnailUrl: thumbUrl.isNotEmpty ? thumbUrl : imgUrl,
      mediumUrl: medUrl.isNotEmpty ? medUrl : imgUrl,
      highResUrl: hiResUrl.isNotEmpty ? hiResUrl : imgUrl,
      cloudinaryPublicId: json['cloudinary_public_id'] as String?,
      width: json['width'] is int
          ? json['width'] as int
          : int.tryParse(json['width']?.toString() ?? ''),
      height: json['height'] is int
          ? json['height'] as int
          : int.tryParse(json['height']?.toString() ?? ''),
      cameraMake: json['camera_make'] as String?,
      cameraModel: json['camera_model'] as String?,
      lens: json['lens'] as String?,
      focalLength: json['focal_length'] as String?,
      aperture: json['aperture'] as String?,
      shutterSpeed: json['shutter_speed'] as String?,
      iso: json['iso'] as String?,
      takenAt: json['taken_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      likesCount: json['likes_count'] is int
          ? json['likes_count'] as int
          : int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
      commentsCount: json['comments_count'] is int
          ? json['comments_count'] as int
          : int.tryParse(json['comments_count']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] == true,
      creator: creatorObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_photo': idPhoto,
      'id_user': idUser,
      'id_category': idCategory,
      'category_name': categoryName,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'medium_url': mediumUrl,
      'high_res_url': highResUrl,
      'cloudinary_public_id': cloudinaryPublicId,
      'width': width,
      'height': height,
      'camera_make': cameraMake,
      'camera_model': cameraModel,
      'lens': lens,
      'focal_length': focalLength,
      'aperture': aperture,
      'shutter_speed': shutterSpeed,
      'iso': iso,
      'taken_at': takenAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'creator': creator?.toJson(),
    };
  }

  PhotoModel copyWith({
    int? idPhoto,
    String? idUser,
    int? idCategory,
    String? categoryName,
    String? title,
    String? description,
    String? imageUrl,
    String? thumbnailUrl,
    String? mediumUrl,
    String? highResUrl,
    String? cloudinaryPublicId,
    int? width,
    int? height,
    String? cameraMake,
    String? cameraModel,
    String? lens,
    String? focalLength,
    String? aperture,
    String? shutterSpeed,
    String? iso,
    String? takenAt,
    String? createdAt,
    String? updatedAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    PhotoCreator? creator,
  }) {
    return PhotoModel(
      idPhoto: idPhoto ?? this.idPhoto,
      idUser: idUser ?? this.idUser,
      idCategory: idCategory ?? this.idCategory,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediumUrl: mediumUrl ?? this.mediumUrl,
      highResUrl: highResUrl ?? this.highResUrl,
      cloudinaryPublicId: cloudinaryPublicId ?? this.cloudinaryPublicId,
      width: width ?? this.width,
      height: height ?? this.height,
      cameraMake: cameraMake ?? this.cameraMake,
      cameraModel: cameraModel ?? this.cameraModel,
      lens: lens ?? this.lens,
      focalLength: focalLength ?? this.focalLength,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      iso: iso ?? this.iso,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      creator: creator ?? this.creator,
    );
  }
}
