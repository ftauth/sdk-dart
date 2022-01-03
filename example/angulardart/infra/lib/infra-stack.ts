import { CfnOutput, RemovalPolicy, Stack, StackProps } from 'aws-cdk-lib';
import { DnsValidatedCertificate } from 'aws-cdk-lib/aws-certificatemanager';
import { OriginAccessIdentity, ViewerCertificate, SSLMethod, SecurityPolicyProtocol, CloudFrontWebDistribution, CloudFrontAllowedMethods } from 'aws-cdk-lib/aws-cloudfront';
import { HostedZone, ARecord, RecordTarget } from 'aws-cdk-lib/aws-route53';
import { CloudFrontTarget } from 'aws-cdk-lib/aws-route53-targets';
import { Bucket, BlockPublicAccess } from 'aws-cdk-lib/aws-s3';
import { Construct } from 'constructs';

export class FTAuthTodosStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    const siteDomain = 'todos.dillonnys.com';
    const zone = HostedZone.fromLookup(this, 'Zone', { domainName: 'dillonnys.com' });

    const originAccessId = new OriginAccessIdentity(this, "OriginAccessIdentity", {
      comment: `OAI for ${id}`
    });

    const certificate = new DnsValidatedCertificate(this, 'SiteCertificate', {
      domainName: siteDomain,
      hostedZone: zone,
      region: 'us-east-1',
    });

    const viewerCertificate = ViewerCertificate.fromAcmCertificate(certificate, {
      sslMethod: SSLMethod.SNI,
      securityPolicy: SecurityPolicyProtocol.TLS_V1_2_2021,
      aliases: [siteDomain]
    });

    const websiteBucket = new Bucket(this, "WebsiteBucket", {
      bucketName: siteDomain,
      autoDeleteObjects: true,
      removalPolicy: RemovalPolicy.DESTROY,
      publicReadAccess: false,
      blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
      websiteIndexDocument: 'index.html',
    });

    websiteBucket.grantRead(originAccessId);

    const distribution = new CloudFrontWebDistribution(this, "WebsiteDistribution", {
      viewerCertificate,
      originConfigs: [
        {
          s3OriginSource: {
            s3BucketSource: websiteBucket,
            originAccessIdentity: originAccessId,
          },
          behaviors: [{
            isDefaultBehavior: true,
            compress: true,
            allowedMethods: CloudFrontAllowedMethods.GET_HEAD_OPTIONS,
          }]
        }
      ],
    });

    new ARecord(this, 'SiteAliasRecord', {
      recordName: siteDomain,
      target: RecordTarget.fromAlias(new CloudFrontTarget(distribution)),
      zone,
    });

    new CfnOutput(this, 'BucketName', {
      value: websiteBucket.bucketName,
    });

    new CfnOutput(this, "CloudFrontUrl", {
      value: distribution.distributionDomainName,
    });

    new CfnOutput(this, "CloudFrontDistributionId", {
      value: distribution.distributionId,
    });
  }
}
