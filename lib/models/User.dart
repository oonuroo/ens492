import 'dart:async';
import 'package:properly_made_nft_market/helpers/marketHelper.dart' as MarketHelper;
import 'package:properly_made_nft_market/models/Nft.dart';
import 'package:properly_made_nft_market/models/NftCollection.dart';
import 'package:web3dart/credentials.dart';
import '../backend/requests.dart';

class User {
  final String address;
  final String username;
  final String profilePicture;
  final String email;
  int NFTLikes;
  int collectionLikes;

  User(
      {required this.address,
      required this.username,
      required this.profilePicture,
      required this.email,
      required this.NFTLikes,
      required this.collectionLikes});

  String get pk => address;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        address: json['uAddress'],
        username: json['username'],
        profilePicture: json['profilePicture'] ?? "https://ia801703.us.archive.org/6/items/twitter-default-pfp/e.png",
        email: json['email'],
        NFTLikes: json['NFTLikes'],
        collectionLikes: json["collectionLikes"]);
  }

  @override
  String toString() =>
      "User(address: $address, username: $username, profilePicture: $profilePicture, email: $email, NFTLikes: $NFTLikes, collectionLikes: $collectionLikes)";

  Future<List<NFT>> get ownedNFTs async {
    var response = await MarketHelper.query("fetchMyNFTs", []) as List<dynamic>;
    var NFTs = response.map((e) => NFT(
        address: e["collection_address"],
        nID: e["nID"],
        name: e["collection"],
        description: e["description"],
        metaDataType: "png",
        dataLink: e["tokenId"],
        collectionName: e["collectionName"],
        creator: e["creator"],
        owner: address,
        marketStatus:
        e["marketStatus"])
    );
    return NFTs.toList();
  }
  Future<List<NFT>> get likedNFTs async {
    List JSONList = await getRequest("favorites", {"user": pk});
    List<NFT> ownedNFTs = JSONList.map((item) => NFT.fromJson(item)).toList();
    return ownedNFTs;
  }

  Future<bool> userLikedNFT(Map<String, dynamic> NFTInfo) async {
    final List JSONList =
        await getRequest("favorites", {...NFTInfo, "user": pk});
    return JSONList.isNotEmpty;
  }

  Future<bool> likeNFT(Map<String, dynamic> NFTInfo,bool liked) async {
    if(liked){
      return (await deleteRequest("favorites", {...NFTInfo, "user": pk}));
    }
    return (await postRequest("favorites", {...NFTInfo, "user": pk}));
  }

  Future<bool> userWatchListedCollection(String address) async {
    final List JSONList =
    await getRequest("watchLists", {"nftCollection": address, "user": pk});
    return JSONList.isNotEmpty;
  }

  Future<bool> watchListCollection(String address, bool watchListed) async {
    if(watchListed){
      return (await deleteRequest("watchLists", {"nftCollection": address, "user": pk}));
    }
    return (await postRequest("watchLists", {"nftCollection": address, "user": pk}));
  }

  Future<List<NFTCollection>> get watchlistedCollections async {
    List JSONList = await getRequest("watchLists", {"user": pk});
    print(JSONList);
    List<NFTCollection> watchListedCollections = JSONList.map((item) => NFTCollection.fromJson(item)).toList();

    return watchListedCollections;
  }
  Future<List<NFTCollection>> get ownedCollections async {
    var JSONList = await MarketHelper.query("getCollections", [EthereumAddress.fromHex(address)])
    .onError((error, stackTrace) {
      print(error);
    });
    JSONList = JSONList.replaceAll("[", "").replaceAll("]","").split(",");
    List<NFTCollection> ownedCollections =
    JSONList.map((item) => NFTCollection.fromJson(item)).toList();
    print(JSONList);
    return ownedCollections;
  }
  Future<bool> watchLists(String address) async {
    List isCollectionFollowed = await getRequest("watchLists", {"user": pk,"nftCollection": address});
    print(isCollectionFollowed);
    return (isCollectionFollowed.isNotEmpty);
  }
}
