import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq/groq.dart';

Future<Groq> groqInit() async {
  await dotenv.load(fileName: ".env");
  Groq groq = Groq(
      apiKey: dotenv.env['GROQ_API']!, model: GroqModel.llama_31_70b_versatile);
  return groq;
}
