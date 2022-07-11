from django.contrib import admin
from .models import School, Student, Tutor
from .models import Tutorship, Message, Meeting

class SchoolAdmin(admin.ModelAdmin):
    pass
admin.site.register(School, SchoolAdmin)

class StudentAdmin(admin.ModelAdmin):
    pass
admin.site.register(Student, StudentAdmin)

class TutorAdmin(admin.ModelAdmin):
    pass
admin.site.register(Tutor, TutorAdmin)

# Register your models here.
class TutorshipAdmin(admin.ModelAdmin):
    pass
admin.site.register(Tutorship, TutorshipAdmin)

class MessageAdmin(admin.ModelAdmin):
    pass
admin.site.register(Message, MessageAdmin)

class MeetingAdmin(admin.ModelAdmin):
    pass
admin.site.register(Meeting, MeetingAdmin)