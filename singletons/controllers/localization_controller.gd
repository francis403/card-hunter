extends Node

signal language_changed(new_locale: String)

const SUPPORTED_LANGUAGES: Dictionary = {
	"en": "English",
	"es": "Español"
}

var current_locale: String = "en"


func set_language(locale: String, save_preference: bool = true) -> void:
	if not SUPPORTED_LANGUAGES.has(locale):
		push_warning("Unsupported locale: ", locale)
		return

	current_locale = locale
	TranslationServer.set_locale(locale)

	if save_preference:
		File.settings.language = current_locale
		File.change_settings()

	language_changed.emit(locale)

func get_current_language_name() -> String:
	return SUPPORTED_LANGUAGES.get(current_locale, "English")

func get_supported_languages() -> Dictionary:
	return SUPPORTED_LANGUAGES

func tr_format(key: String, args: Array = []) -> String:
	var translated = tr(key)
	if args.is_empty():
		return translated

	# Replace placeholders {0}, {1}, etc. with args
	for i in range(args.size()):
		translated = translated.replace("{%d}" % i, str(args[i]))

	return translated
