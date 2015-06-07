# LTTextView

You need to create text with several buttons in it? You can use UIWebView, UIlabels with UIButtons, another ways. But when you have localizations for 10 or more languages and UI designer wants to have each button with few words on one line - task becomes "pain in ass". You can write your own code to manage this task or simply use LTTextView.

## Usage

Add LTTextView to your project and use this view to display text with interactive buttons. You can customize whole text or/and each button text appearance using NSAttributedString attributes. You should implement LTLinkTextViewDelegate method to get callback from the text view.

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).