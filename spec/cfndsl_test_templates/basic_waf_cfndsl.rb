CloudFormation {

  Resource('rWebAcl') {
    Type 'AWS::WAF::WebACL'

    Property 'Name', 'dromedaryWebAcl'

    Property 'DefaultAction', { 'Type' => 'ALLOW' }
    Property 'MetricName', 'dromedaryWebAclMetric'
    Property 'Rules', [
      {
        'Action' =>  { 'Type' => 'BLOCK' },
        'Priority' => 100,
        'RuleId' => Ref('rWafIpSetRule')
      }
    ]
  }

  #let some downstream agent fill in the details
  Resource('rTorBlackListedIpSet') {
    Type 'AWS::WAF::IPSet'
    Property 'Name', 'torExitPointIpSet'
  }

  Resource('rWafIpSetRule') {
    Type 'AWS::WAF::Rule'

    Property 'Name', 'torRule'
    Property 'MetricName', 'torRuleMetric'
    Property 'Predicates', [
      {
        'DataId' => Ref('rTorBlackListedIpSet'),
        'Negated' => false,
        'Type' => 'IPMatch'
      }
    ]
  }
}
