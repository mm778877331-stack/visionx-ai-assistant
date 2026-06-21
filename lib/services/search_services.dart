import  'dart:convert' ;
import  'package:http/http.dart'  as http;

class SearchService {
  // ضع مفتاح SerpApi الخاص بك هنا
  static const String _serpApiKey = "67d9d63441317a69e4b86b6901b36758aa3f058df89a68c828bc6b800800e555"; // غيره بمفتاحك
  
  // البحث في الويب
  static Future<String> searchWeb(String query) async {
    try {
      final url = Uri.parse(
         'https://serpapi.com/search?q=${Uri.encodeComponent(query)}&api_key=$_serpApiKey&engine=google&hl=ar' 
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("الخادم بطيء، حاول مرة أخرى")
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // استخراج النتائج من الـ API
        final organicResults = data[ 'organic_results' ] as List?;
        
        if (organicResults != null && organicResults.isNotEmpty) {
          // خذ أول 3 نتائج واستخرج ملخصاتها
          final summaries = <String>[];
          for (var i = 0; i < (organicResults.length > 3 ? 3 : organicResults.length); i++) {
            final result = organicResults[i];
            final title = result[ 'title' ] ?? '' ;
            final snippet = result[ 'snippet' ] ?? '' ;
            if (snippet.isNotEmpty) {
              summaries.add( '$title: $snippet' );
            }
          }
          
          if (summaries.isNotEmpty) {
            return summaries.join( '\n\n' );
          }
        }
        return  '' ;
      } else {
        print( '❌ فشل البحث: ${response.statusCode}' );
        return  '' ;
      }
    } catch (e) {
      print( '❌ خطأ في البحث: $e' );
      return  '' ;
    }
  }
  
  // البحث عن أخبار حديثة (مخصص للرياضة والأحداث)
  static Future<String> searchNews(String query) async {
    try {
      final url = Uri.parse(
         'https://serpapi.com/search?q=${Uri.encodeComponent(query)}&api_key=$_serpApiKey&engine=google&tbm=nws&hl=ar' 
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newsResults = data[ 'news_results' ] as List?;
        
        if (newsResults != null && newsResults.isNotEmpty) {
          final summaries = <String>[];
          for (var i = 0; i < (newsResults.length > 3 ? 3 : newsResults.length); i++) {
            final result = newsResults[i];
            final title = result[ 'title' ] ??  '' ;
            final snippet = result[ 'snippet' ] ?? ''  ;
            if (snippet.isNotEmpty) {
              summaries.add( '$title: $snippet' );
            }
          }
          return summaries.join( '\n\n' );
        }
      }
      return ''  ;
    } catch (e) {
      return '' ;
    }
  }
}