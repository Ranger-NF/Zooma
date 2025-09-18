from django.contrib import admin

from .models import Question


# Register your models here.

def populate_questions(apps, schema_editor):
    Question = apps.get_model('question','Question')

    if Question.objects.exists():
        return

    questions_to_add = [
        "Upload a photo of something red.",
        "Upload a photo of a tree.",
        "Upload a photo of a book.",
        "Upload a photo of something you can write with.",
        "Upload a photo of a source of light.",
        "Upload a photo of something you can drink from.",
        "Upload a photo of a piece of technology.",
        "Upload a photo of something circular.",
        "Upload a photo of your shoes.",
        "Upload a photo of a leaf.",
    ]
    for q_text in questions_to_add:
        Question.objects.create(text=q_text)

class QuestionAdmin(admin.ModelAdmin):
    list_display = ('id', 'text')

admin.site.register(Question, QuestionAdmin)