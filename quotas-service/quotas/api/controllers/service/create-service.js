module.exports = {


  friendlyName: 'Create service',


  description: '',


  inputs: {
    name: {
      type: 'string',
      description: 'service name',
      required: true
    },
    description: {
      type: 'string',
      description: 'service description'
    }
  },


  exits: {
  },


  fn: async function (inputs, exits) {

    let x = await Service.create({
      name: inputs.name,
      description: inputs.description
    });
    console.log(x);
    return exits.success();

  }


};
