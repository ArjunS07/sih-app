from django.contrib import admin
from .models import Tutorship, Message, Meeting

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