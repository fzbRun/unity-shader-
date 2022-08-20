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
        //打开向导
        //"Render Cubemap"是打开的窗口名，"Render"是按钮名，点击时调用OnWizardCreate()方法
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Render Irradiancemap", "Render");
    }

    //打开向导或者在向导中更改了其他内容的时候调用
    private void OnWizardUpdate()
    {
        helpString = "选择渲染位置及需要设置的cubemap";
        //isValid为true的时候，“Create”按钮才能点击
        isValid = Environmentmap != null && makeIrradianceShader != null;
    }

    //点击创建按钮时调用
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
