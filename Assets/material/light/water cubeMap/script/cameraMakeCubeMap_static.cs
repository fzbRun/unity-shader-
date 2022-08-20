using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubeMap : ScriptableWizard
{
    public Transform renderTrans;
    public Cubemap cubemap;

    [MenuItem("Tools/RenderCubemap")]
    static void RenderCubemap()
    {
        //打开向导
        //"Render Cubemap"是打开的窗口名，"Render"是按钮名，点击时调用OnWizardCreate()方法
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Render Cubemap", "Render");
    }

    //打开向导或者在向导中更改了其他内容的时候调用
    private void OnWizardUpdate()
    {
        helpString = "选择渲染位置及需要设置的cubemap";
        //isValid为true的时候，“Create”按钮才能点击
        isValid = renderTrans != null && cubemap != null;
    }

    //点击创建按钮时调用
    private void OnWizardCreate()
    {
        GameObject go = new GameObject();
        go.transform.position = renderTrans.position;
        Camera camera = go.AddComponent<Camera>();
        //用户提供的Cubemap传递给RenderToCubemap函数，生成六张图片
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }
}