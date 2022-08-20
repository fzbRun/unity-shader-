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
        //����
        //"Render Cubemap"�Ǵ򿪵Ĵ�������"Render"�ǰ�ť�������ʱ����OnWizardCreate()����
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Render Cubemap", "Render");
    }

    //���򵼻��������и������������ݵ�ʱ�����
    private void OnWizardUpdate()
    {
        helpString = "ѡ����Ⱦλ�ü���Ҫ���õ�cubemap";
        //isValidΪtrue��ʱ�򣬡�Create����ť���ܵ��
        isValid = renderTrans != null && cubemap != null;
    }

    //���������ťʱ����
    private void OnWizardCreate()
    {
        GameObject go = new GameObject();
        go.transform.position = renderTrans.position;
        Camera camera = go.AddComponent<Camera>();
        //�û��ṩ��Cubemap���ݸ�RenderToCubemap��������������ͼƬ
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }
}