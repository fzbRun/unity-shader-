using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class makeIrradianceMap : ScriptableWizard
{

    string[] skyBoxImage = new string[6] { "frontImage", "rightImage", "backImage", "leftImage", "upImage", "downImage" };
    Vector3[] skyDirection = new Vector3[]{ new Vector3(0, 0, 0), new Vector3(0, -90, 0), new Vector3(0, 180, 0), new Vector3(0, 90, 0), new Vector3(-90, 0, 0), new Vector3(90, 0, 0) };

    public Cubemap Environmentmap;
    public Shader makeIrradianceShader;
    private Material makeIrradianceMaterial;
    public Material material
    {
        get
        {

            makeIrradianceMaterial = CheckShaderAndCreateMaterial(makeIrradianceShader, makeIrradianceMaterial);
            return makeIrradianceMaterial;

        }
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {

        if (shader == null)
        {
            return null;
        }

        if (shader.isSupported && material && material.shader == shader)
        {
            return material;
        }

        if (!shader.isSupported)
        {
            return null;
        }
        else
        {

            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
            {
                return material;
            }
            else
            {
                return null;
            }

        }

    }

    [MenuItem("Tools/RenderCubemap")]
    static void RenderCubemap()
    {
        //����
        //"Render Cubemap"�Ǵ򿪵Ĵ�������"Render"�ǰ�ť�������ʱ����OnWizardCreate()����
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Render Irradiancemap", "Render");
    }

    //���򵼻��������и������������ݵ�ʱ�����
    private void OnWizardUpdate()
    {
        helpString = "ѡ����Ⱦλ�ü���Ҫ���õ�cubemap";
        //isValidΪtrue��ʱ�򣬡�Create����ť���ܵ��
        isValid = Environmentmap != null && makeIrradianceShader != null;
    }

    //���������ťʱ����
    private void OnWizardCreate()
    {
        if(material != null)
        {

            material.SetTexture("_EnvironmentMap", Environmentmap);

            RenderTexture environmentTexture = RenderTexture.GetTemporary(64, 64, 0);
            Texture2D renderTarget = new Texture2D(64, 64, TextureFormat.RGBA32, false);

            environmentTexture.enableRandomWrite = true;
            environmentTexture.Create();

            renderTarget.Apply();

            for(int i = 0;i < 6; i++)
            {

                Graphics.Blit(null, environmentTexture, material, 0);
                Graphics.ConvertTexture(environmentTexture, renderTarget);
                environmentTexture.Release();
                byte[] irradianceTexture = renderTarget.EncodeToPNG();
                System.IO.File.WriteAllBytes(System.IO.Path.Combine("i.png"), irradianceTexture);

            }

        }
    }

}
