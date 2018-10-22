module.exports = {


  friendlyName: 'Register instance',


  description: '',


  inputs: {
    serviceId: {
      type: 'number',
      description: 'service foreign key',
      required: true
    },
    name: {
      type: 'string',
      description: 'instance name'
    },
    address: {
      type: 'string',
      required: true,
      description: 'service instance IP'
    }
  },


  exits: {

  },


  fn: async function (inputs, exits) {

    return exits.success();

  }


};
