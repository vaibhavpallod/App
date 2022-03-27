import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uber_hacktag_group_booking/Enter/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
          query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
        padding: EdgeInsets.all(16.0),
        child: Text('Enter your address',style: GoogleFonts.workSans(fontSize: 16),),
      )
          : snapshot.hasData
          ? ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title:
          Text((snapshot.data[index] as Suggestion).description,style: GoogleFonts.workSans(fontSize: 14),),
          onTap: () {
            close(context, snapshot.data[index] as Suggestion);
          },
        ),
        itemCount: snapshot.data.length,
      )
          : Container(child: Text('Loading...',style: GoogleFonts.workSans(fontSize: 14),)),
    );
  }
}