#include "HelloJAWTWorld.h"
#include "jawt_md.h"

/*
 * Class:    HelloJAWTWorld 
 * Method:    paint
 * Signature: (Ljava/awt/Graphics;)V
 */


JNIEXPORT void JNICALL Java_HelloJAWTWorld_paint
(JNIEnv* env, jobject canvas, jobject graphics)
{
    JAWT awt;
    JAWT_DrawingSurface* ds;
    JAWT_DrawingSurfaceInfo* dsi;
    JAWT_X11DrawingSurfaceInfo* dsi_x11;
    jboolean result;
    jint lock;
    GC gc;
    jobject ref;

    /* Get the AWT */
    awt.version = JAWT_VERSION_1_4;
    if (JAWT_GetAWT(env, &awt) == JNI_FALSE) {
        printf("AWT Not found\n");
        return;
    }

    printf("awt found\n");

    /* Lock the AWT */
    awt.Lock(env);

    printf("awt lock success\n");

    /* Unlock the AWT */
    awt.Unlock(env);

    printf("awt unlock success\n");

    /* Get the drawing surface */
    ds = awt.GetDrawingSurface(env, canvas);
    if (ds == NULL) {
        printf("NULL drawing surface\n");
        return;
    }

    printf("get drawing surface success\n");

    awt_DrawingSurface_Lock_Custom(ds);

    /* Lock the drawing surface */
    lock = ds->Lock(ds);
    printf("Lock value %d\n", (int)lock);
    if((lock & JAWT_LOCK_ERROR) != 0) {
        printf("Error locking surface\n");
        awt.FreeDrawingSurface(ds);
        return;
    }

    printf("Lock the drawing surface success\n");

    /* Get the drawing surface info */
    dsi = ds->GetDrawingSurfaceInfo(ds);
    if (dsi == NULL) {
        printf("Error getting surface info\n");
        ds->Unlock(ds);
        awt.FreeDrawingSurface(ds);
        return;
    }

   printf("Get the drawing surface info success\n");


    /* Get the platform-specific drawing info */
    dsi_x11 = (JAWT_X11DrawingSurfaceInfo*)dsi->platformInfo;

    /* Now paint */
    gc = XCreateGC(dsi_x11->display, dsi_x11->drawable, 0, 0);
    XSetForeground(dsi_x11->display, gc, 0);
    XFillRectangle(dsi_x11->display, dsi_x11->drawable, gc,
                   5, 5, 90, 90);
    XFreeGC(dsi_x11->display, gc);
    ref = awt.GetComponent(env, (void*)(dsi_x11->drawable));
    if (!(*env)->IsSameObject(env, ref, canvas)) {
        printf("Error! Different objects!\n");
    }

    printf("Same objects\n");

    /* Free the drawing surface info */
    ds->FreeDrawingSurfaceInfo(dsi);

    /* Unlock the drawing surface */
    ds->Unlock(ds);

    /* Free the drawing surface */
    awt.FreeDrawingSurface(ds);
}

JNIEXPORT jint JNICALL awt_DrawingSurface_Lock_Custom(JAWT_DrawingSurface* ds)
{
    printf("awt_DrawingSurface_Lock_Custom - Begin\n");
    JNIEnv* env;
    jobject target, peer;
    jclass componentClass;
    jint drawState;

    env = ds->env;
    target = ds->target;

   /* Make sure the target is a java.awt.Component */
    componentClass = (*env)->FindClass(env, "java/awt/Component");

    if (componentClass == NULL)
	{
      		printf("awt_DrawingSurface_Lock_Custom -Target is not a component\n");
	}
	else
	{
      		printf("awt_DrawingSurface_Lock_Custom -Target is component\n");
	}

    printf("awt_DrawingSurface_Lock_Custom - End\n");

    
}
