from django.contrib import admin
from .models import School, Student, Tutor
from .models import ZoomMeeting, Tutorship, TutorshipReport
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

class ZoomMeetingAdmin(admin.ModelAdmin):
    pass
admin.site.register(ZoomMeeting, ZoomMeetingAdmin)

class TutorshipReportAdmin(admin.ModelAdmin):
    pass
admin.site.register(TutorshipReport, TutorshipReportAdmin)